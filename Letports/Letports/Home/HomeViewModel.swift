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

struct SampleGathering2 {
    var gatherImage: URL?
    var gatherName: String?
}

class HomeViewModel {
    
    @Published var latestYoutubeVideos: [YoutubeVideo] = []
    @Published var gatherings: [SampleGathering2] = []
    
    @Published var team: Team?
    
    private var cancellables = Set<AnyCancellable>()
    private let youtubeAPIKey = ""
    
    init() {
        getTeamData()
        //fetchGatherings(forTeam: "LG 트윈스")
    }
    
    func getTeamData() {
        FM.getData(collection: "SportsTeams", document: "XrNMkdeu9OHkZDF7yG9N", type: Team.self)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("에러!!: Error fetching gatherings: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] team in
                print("가져온 데이터: ", team)
                self?.team = team
                self?.fetchLatestYoutubeVideos()
            }
            .store(in: &cancellables)
    }
    
    private func fetchLatestYoutubeVideos() {
        guard let team = team else { return }
        
        let channelID = team.youtubeChannelID
        
        let apiUrlString = "https://www.googleapis.com/youtube/v3/search?key=\(self.youtubeAPIKey)&channelId=" +
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
