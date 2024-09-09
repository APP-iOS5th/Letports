//
//  HomeViewModel.swift
//  Letports
//
//  Created by 홍준범 on 8/19/24.
//

import Foundation
import UIKit
import Combine
import FirebaseFirestore

enum HomeCellType {
    case profile
    case latestVideoTitleLabel
    case youtubeThumbnails
    case recommendGatheringTitleLabel
    case recommendGatheringLists
}


struct YoutubeVideo {
    let title: String
    let thumbnailURL: URL
    let videoURL: URL
}

struct YoutubeAPIResponse: Codable {
    struct Item: Codable {
        struct ID: Codable {
            let videoId: String?
        }
        struct Snippet: Codable {
            let title: String
            struct Thumbnails: Codable {
                struct Default: Codable {
                    let url: String
                }
                let medium: Default
            }
            let thumbnails: Thumbnails
        }
        let id: ID
        let snippet: Snippet
    }
    let items: [Item]
}

class RSSParser: NSObject, XMLParserDelegate {
    
    private var currentElement = ""
    private var currentTitle = ""
    private var currentThumbnailURL = ""
    private var currentVideoID = ""
    
    var videos: [YoutubeVideo] = []
    
    func parseRSSFeed(from data: Data) -> Future<[YoutubeVideo], Error> {
        return Future { [weak self] promise in
            let parser = XMLParser(data: data)
            parser.delegate = self
            let success = parser.parse()
            
            if success {
                promise(.success(self?.videos ?? []))
            } else {
                promise(.failure(NSError(domain: "RSSParsing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Parsing failed"])))
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "media:thumbnail" {
            if let url = attributeDict["url"] {
                currentThumbnailURL = url
            }
        }
        
        if elementName == "link" {
            if let href = attributeDict["href"], href.contains("watch?v=") {
                currentVideoID = href.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "title" {
            currentTitle += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry" {
            if let thumbnailURL = URL(string: currentThumbnailURL), let videoURL = URL(string: "https://www.youtube.com/watch?v=\(currentVideoID)") {
                let video = YoutubeVideo(title: currentTitle, thumbnailURL: thumbnailURL, videoURL: videoURL)
                videos.append(video)
            }
            
            currentTitle = ""
            currentThumbnailURL = ""
            currentVideoID = ""
        }
    }
}

class HomeViewModel {
    
    @Published var latestYoutubeVideos: [YoutubeVideo] = []
    @Published var recommendGatherings: [Gathering] = []
    @Published var team: SportsTeam?
    
    weak var delegate: HomeCoordinatorDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    private var cellType: [HomeCellType] {
        var cellTypes: [HomeCellType] = []
        cellTypes.append(.profile)
        cellTypes.append(.latestVideoTitleLabel)
        cellTypes.append(.youtubeThumbnails)
        cellTypes.append(.recommendGatheringTitleLabel)
        cellTypes.append(.recommendGatheringLists)
        return cellTypes
    }
    
    func getCellTypes() -> [HomeCellType] {
        return self.cellType
    }
    
    func getCellCount() -> Int {
        return self.cellType.count
    }
    
    init() {
        getTeamData()
    }
    
    func getTeamData() {
        guard let userData = UserManager.shared.currentUser else {
            return
        }
        let collectionPath: [FirestorePathComponent] = [
            .collection(.sports),
            .document(userData.userSports),
            .collection(.sportsTeam),
            .document(userData.userSportsTeam)
        ]
        
        FM.getData(pathComponents: collectionPath, type: SportsTeam.self)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("get Data Error :" ,error)
                }
            } receiveValue: { [weak self] team in
                self?.team = team.first
                self?.fetchLatestYoutubeVideos()
                self?.fetchGatherings(forTeam: team.first?.teamUID ?? "")
            }
            .store(in: &cancellables)
        
    }
    
    private func fetchLatestYoutubeVideos() {
        guard let team = team else { return }
        
        let rssFeedURL = "https://www.youtube.com/feeds/videos.xml?channel_id=\(team.youtubeChannelID)"
        
        guard let url = URL(string: rssFeedURL) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .flatMap { data in
                RSSParser().parseRSSFeed(from: data)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching Youtube videos: \(error)")
                }
            }, receiveValue: { [weak self] videos in
                self?.latestYoutubeVideos = videos
            })
            .store(in: &cancellables)
    }
          
    func fetchGatherings(forTeam teamName: String) {
        db.collection("Gatherings")
            .whereField("GatheringSportsTeam", isEqualTo: teamName)
            .getDocuments { [weak self] (snapshot, error) in
                
                if let error = error {
                    print("Error fetching gatherings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                let gatherings = documents.compactMap { document in
                    try? document.data(as: Gathering.self)
                }
                
                let sortedGatherings = gatherings.sorted { gathering1, gathering2 in
                    return gathering1.gatheringCreateDate.dateValue() < gathering2.gatheringCreateDate.dateValue()
                }
                
                self?.recommendGatherings = Array(sortedGatherings.prefix(5))
            }
    }
    
    //화면 전환
    func presentURLController(with url: URL) {
        self.delegate?.presentURLController(with: url)
    }
    
    func presentTeamChangeContorller() {
        self.delegate?.presentTeamChangeController()
    }
    
    func pushGatheringDetailController(gatheringUID: String, teamColor: String) {
        self.delegate?.pushGatheringDetailController(gatheringUID: gatheringUID, teamColor: teamColor)
    }
    
    
}
