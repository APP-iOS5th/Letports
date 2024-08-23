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

struct Team {
    var teamLogo: URL?
    var teamName: String?
    var homepageURL: URL?
    var instagramURL: URL?
    var youtubeURL: URL?
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

struct Gathering {
    var gatherImage: URL?
    var gatherName: String?
}

protocol FirebaseServiceProtocol {
    func fetchTeamData(teamUID: String) -> AnyPublisher<Team, Error>
    func fetchGatherings(forTeam teamName: String) -> AnyPublisher<[Gathering], Error>
}

class FirebaseService: FirebaseServiceProtocol {
    func fetchTeamData(teamUID: String) -> AnyPublisher<Team, Error> {
        return Future { promise in
            let db = Firestore.firestore()
            let docRef = db.collection("SportsTeams").document(teamUID).collection("TeamSNS").document("G9wIwb9nfFEJm5nNIcML")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    print(data)
                    
                    let teamName = (data?["TeamName"] as? String)
                    let teamLogoURL = (data?["TeamLogo"] as? String).flatMap { URL(string: $0) }
                    let homepageURL = (data?["Homepage"] as? String).flatMap { URL(string: $0) }
                    let instagramURL = (data?["Instagram"] as? String).flatMap { URL(string: $0) }
                    let youtubeURL = (data?["Youtube"] as? String).flatMap { URL(string: $0) }
                    
                    let team = Team(
                        teamLogo: teamLogoURL,
                        teamName: teamName,
                        homepageURL: homepageURL,
                        instagramURL: instagramURL,
                        youtubeURL: youtubeURL
                    )
                    promise(.success(team))
                } else if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchGatherings(forTeam teamName: String) -> AnyPublisher<[Gathering], Error> {
        return Future { promise in
            let db = Firestore.firestore()
            db.collection("Gatherings")
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        var gatherings: [Gathering] = []
                        querySnapshot?.documents.forEach { document in
                            let data = document.data()
                            if let sportsTeam = data["GatheringSportsTeam"] as? String, sportsTeam == teamName {
                                let gatherName = data["GatherName"] as? String
                                if let imageURLString = data["GatherImage"] as? String {
                                    if let imageURL = URL(string: imageURLString) {
                                        print("Valid Image URL for document \(document.documentID): \(imageURLString)")
                                        let gathering = Gathering(gatherImage: imageURL, gatherName: gatherName)
                                        gatherings.append(gathering)
                                    } else {
                                        print("Invalid image URL format for document: \(document.documentID)")
                                    }
                                } else {
                                    print("Missing GatherImage field for document: \(document.documentID)")
                                }
                            }
                        }
                        promise(.success(gatherings))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

class HomeViewModel {
    
    @Published var team: Team?
    @Published var latestYoutubeVideos: [YoutubeVideo] = []
    @Published var gatherings: [Gathering] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseService: FirebaseServiceProtocol
    private let youtubeAPIKey = ""
    
    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
        fetchTeamData()
        fetchGatherings(forTeam: "LG 트윈스")
    }
    
    func fetchTeamData() {
        let teamUID = "YcXsJAgoFtqS3XZ0HdZu"
        
        firebaseService.fetchTeamData(teamUID: teamUID)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching team data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] team in
                self?.team = team
                self?.fetchLatestYoutubeVideos()
            })
            .store(in: &cancellables)
    }
    
    private func fetchLatestYoutubeVideos() {
        guard let youtubeURL = team?.youtubeURL else { return }
        
        extractChannelID(from: youtubeURL)
            .flatMap { channelID -> AnyPublisher<[YoutubeVideo], Error> in
                let apiUrlString = "https://www.googleapis.com/youtube/v3/search?key=\(self.youtubeAPIKey)&channelId=\(channelID)&part=snippet&order=date&maxResults=2"
                
                guard let apiUrl = URL(string: apiUrlString) else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
                }
                
                return URLSession.shared.dataTaskPublisher(for: apiUrl)
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
                            return YoutubeVideo(title: item.snippet.title, thumbnailURL: thumbnailURL, videoURL: videoURL)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching YouTube videos: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] videos in
                self?.latestYoutubeVideos = videos
            })
            .store(in: &cancellables)
    }
    
    private func extractChannelID(from url: URL) -> AnyPublisher<String, Error> {
        let urlString = url.absoluteString
        
        if urlString.contains("youtube.com/channel/") {
            // 채널 ID가 명시된 URL에서 채널 ID 추출
            if let range = urlString.range(of: "channel/") {
                let channelID = String(urlString[range.upperBound...])
                return Just(channelID)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        } else if urlString.contains("youtube.com/user/") || urlString.contains("youtube.com/c/") {
            // 사용자 이름 기반 URL 또는 커스텀 URL 처리
            let usernameOrCustomName = urlString.components(separatedBy: "/").last ?? ""
            return fetchChannelID(for: usernameOrCustomName)
        }
        
        // 채널 ID를 추출할 수 없으면 오류 반환
        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    
    // 유튜브 채널 아이디 가져오기
    private func fetchChannelID(for usernameOrCustomURL: String) -> AnyPublisher<String, Error> {
        let apiUrlString = "https://www.googleapis.com/youtube/v3/channels?key=\(youtubeAPIKey)&forUsername=\(usernameOrCustomURL)&part=id"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: apiUrl)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: YoutubeChannelResponse.self, decoder: JSONDecoder())
            .compactMap { $0.items.first?.id }
            .eraseToAnyPublisher()
    }
    
    struct YoutubeChannelResponse: Codable {
        struct Item: Codable {
            let id: String
        }
        let items: [Item]
    }
    
    func fetchGatherings(forTeam teamName: String) {
        firebaseService.fetchGatherings(forTeam: teamName)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching gatherings: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] gatherings in
                self?.gatherings = gatherings
            })
            .store(in: &cancellables)
    }
    
}
