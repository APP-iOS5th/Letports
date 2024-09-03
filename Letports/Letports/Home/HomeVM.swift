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

class HomeViewModel {
    
    @Published var latestYoutubeVideos: [YoutubeVideo] = []
    @Published var gatherings: [Gathering] = []
    @Published var recommendGatherings: [Gathering] = []
    @Published var team: Team?
    
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
        
        FM.getData(pathComponents: collectionPath, type: Team.self)
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
        
        let channelID = team.youtubeChannelID
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String else {
            print("API Key not found in Info.plist")
            return
        }
        
        let apiUrlString = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&channelId=" +
        "\(channelID)&part=snippet&order=date&maxResults=2"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: apiUrl)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: YoutubeAPIResponse.self, decoder: JSONDecoder())
            .map { response in
                response.items.compactMap { item -> YoutubeVideo? in
                    guard let videoId = item.id.videoId,
                          let thumbnailURL = URL(string: item.snippet.thumbnails.medium.url),
                          let videoURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") else {
                        return nil
                    }
                    return YoutubeVideo(title: item.snippet.title,
                                        thumbnailURL: thumbnailURL,
                                        videoURL: videoURL)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching YouTube videos: \(error)")
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
    
    func pushGatheringDetailController(gatheringUID: String) {
        self.delegate?.pushGatheringDetailController(gatheringUID: gatheringUID)
    }
}
