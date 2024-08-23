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

struct SampleTeam: Codable {
    var homepage: String
    var instagram: String
    var sportsUID: String
    var teamHomeTown: String
    var teamLogo: String
    var teamName: String
    var teamStadium: String
    var teamStartDate: String
    var teamUID: String
    var youtube: String
    
    enum CodingKeys: String, CodingKey {
        case homepage = "Homepage"
        case instagram = "Instagram"
        case sportsUID = "SportsUID"
        case teamHomeTown = "TeamHomeTown"
        case teamLogo = "TeamLogo"
        case teamName = "TeamName"
        case teamStadium = "TeamStadium"
        case teamStartDate = "TeamStartDate"
        case teamUID = "TeamUID"
        case youtube = "Youtube"
    }
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

class HomeViewModel {
    
    @Published var latestYoutubeVideos: [YoutubeVideo] = []
    @Published var gatherings: [Gathering] = []
    
    @Published var sampleTeam: SampleTeam?
    
    private var cancellables = Set<AnyCancellable>()
    private let youtubeAPIKey = ""
    
    init() {
        getTeamData()
        //fetchGatherings(forTeam: "LG 트윈스")
    }
    
    func getTeamData() {
        FM.getData(collection: "SportsTeams", documnet: "90uZPXcm9FNFRvXAyIND", type: SampleTeam.self)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("에러!!: Error fetching gatherings: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] team in
                print("가져온 데이터: ", team)
                self?.sampleTeam = team
                self?.fetchLatestYoutubeVideos(urlStr: team.youtube)
            }
            .store(in: &cancellables)
    }
    
    private func fetchLatestYoutubeVideos(urlStr: String) {
        guard let team = sampleTeam, let youtubeURL = URL(string: team.youtube) else { return }
        
        extractChannelID(from: youtubeURL)
            .flatMap { channelID -> AnyPublisher<[YoutubeVideo], Error> in
                let apiUrlString = "https://www.googleapis.com/youtube/v3/search?key=\(self.youtubeAPIKey)&channelId=" +
                "\(channelID)&part=snippet&order=date&maxResults=2"
                
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
                            return YoutubeVideo(title: item.snippet.title,
                                                thumbnailURL: thumbnailURL,
                                                videoURL: videoURL)
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
        let apiUrlString =
        "https://www.googleapis.com/youtube/v3/channels?key=\(youtubeAPIKey)&forUsername=\(usernameOrCustomURL)&part=id"
        
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
    
//    func fetchGatherings(forTeam teamName: String) {
//        firebaseService.fetchGatherings(forTeam: teamName)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print("Error fetching gatherings: \(error)")
//                case .finished:
//                    break
//                }
//            }, receiveValue: { [weak self] gatherings in
//                self?.gatherings = gatherings
//            })
//            .store(in: &cancellables)
//    }
}
