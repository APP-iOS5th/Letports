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
    let teamLogo: URL?
    let teamName: String?
    let homepageURL: URL?
    let instagramURL: URL?
    let youtubeURL: URL?
}
protocol FirebaseServiceProtocol {
    func fetchTeamData(teamUID: String) -> AnyPublisher<Team, Error>
}

class FirebaseService: FirebaseServiceProtocol {
    func fetchTeamData(teamUID: String) -> AnyPublisher<Team, Error> {
        return Future { promise in
            let db = Firestore.firestore()
            let docRef = db.collection("SportsTeams").document(teamUID).collection("TeamSNS").document("G9wIwb9nfFEJm5nNIcML")
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let teamLogoURL = (data?["TeamLogo"] as? String).flatMap { URL(string: $0) }
                    let homepageURL = (data?["Homepage"] as? String).flatMap { URL(string: $0) }
                    let instagramURL = (data?["Instagram"] as? String).flatMap { URL(string: $0) }
                    let youtubeURL = (data?["Youtube"] as? String).flatMap { URL(string: $0) }
                    
                    let team = Team(
                        teamLogo: teamLogoURL,
                        teamName: data?["TeamName"] as? String ?? "",
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
}

class HomeViewModel {
    
    @Published var teamLogo: URL?
    @Published var teamName: String = ""
    @Published var homepageURL: URL?
    @Published var instagramURL: URL?
    @Published var youtubeURL: URL?
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol = FirebaseService()) {
        self.firebaseService = firebaseService
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
                self?.teamName = team.teamName ?? ""
                self?.homepageURL = team.homepageURL
                self?.instagramURL = team.instagramURL
                self?.youtubeURL = team.youtubeURL
            })
            .store(in: &cancellables)
    }
}
