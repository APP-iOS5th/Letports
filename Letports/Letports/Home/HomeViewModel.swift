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

class HomeViewModel {
    
    @Published var teamLogo: String = ""
    @Published var teamName: String = ""
    @Published var homeURL: URL?
    @Published var instagramURL: URL?
    @Published var youtubeURL: URL?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTeamData()
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
                self?.teamLogo = team.teamLogo
                self?.teamName = team.teamName
                self?.homeURL = URL(string: team.homeURL)
                self?.instagramURL = URL(string: team.instagramURL)
                self?.youtubeURL = URL(string: team.youtubeURL)
            })
            .store(in: &cancellables)
    }
    
    func updateTeamLogo(_ newLogo: String) {
            self.teamLogo = newLogo
        }
        
        func updateTeamName(_ newName: String) {
            self.teamName = newName
        }
        
        func updateHomeURL(_ url: URL?) {
            self.homeURL = url
        }
        
        func updateInstagramURL(_ url: URL?) {
            self.instagramURL = url
        }
        
        func updateYoutubeURL(_ url: URL?) {
            self.youtubeURL = url
        }
    
}
