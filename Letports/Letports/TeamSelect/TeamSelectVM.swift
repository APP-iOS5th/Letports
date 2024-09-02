//
//  SelectTeamVM.swift
//  Letports
//
//  Created by John Yun on 8/24/24.
//

import Foundation
import Combine
import Kingfisher


class TeamSelectVM {
    struct Sports: Hashable, Codable {
        let id: String
        let name: String
        let sportsUID: String
    }
    
    struct Team: Hashable, Codable {
        let id: String
        let name: String
        let logoUrl: String
        let sports: String
        let teamUID: String
    }
    
    @Published var sportsCategories: [Sports] = []
    @Published var allTeams: [Team] = []
    @Published var filteredTeams: [Team] = []
    @Published var selectedSports: Sports?
    @Published var selectedTeam: Team?
    
    private var cancellables = Set<AnyCancellable>()
    
    func selectSports(_ sports: Sports) {
        selectedSports = sports
        filteredTeams = allTeams.filter { $0.sports == sports.id }
    }
    
    func selectTeam(_ team: Team?) {
        selectedTeam = team
    }
    
    func loadData(completion: @escaping () -> Void) {
        loadSportsCategories { [weak self] in
            self?.loadAllTeams {
                completion()
            }
        }
    }
    
    private func loadSportsCategories(completion: @escaping () -> Void) {
        FM.getSportsCategories()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading sports categories: \(error)")
                }
            }, receiveValue: { [weak self] sportsCategories in
                self?.sportsCategories = sportsCategories
                completion()
            })
            .store(in: &cancellables)
    }
    
    private func loadAllTeams(completion: @escaping () -> Void) {
        Publishers.MergeMany(sportsCategories.map { sports in
            FM.getSportsTeams(sports.id)
        })
        .collect()
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error loading teams: \(error)")
            }
        }, receiveValue: { [weak self] teamsArray in
            self?.allTeams = teamsArray.flatMap { $0 }
            completion()
        })
        .store(in: &cancellables)
    }
}

extension TeamSelectVM {
    func updateUserSportsAndTeam(sports: Sports, team: Team) -> AnyPublisher<Void, Error> {
        guard let currentUser = UserManager.shared.currentUser else {
            return Fail(error: NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user found"]))
                .eraseToAnyPublisher()
        }
        
        let updatedUser = LetportsUser(
            email: currentUser.email,
            image: currentUser.image,
            nickname: currentUser.nickname,
            simpleInfo: currentUser.simpleInfo,
            uid: currentUser.uid,
            userSports: sports.sportsUID,
            userSportsTeam: team.teamUID
        )
        
        return FM.updateData(collection: "Users", document: currentUser.uid, data: updatedUser)
            .handleEvents(
                receiveSubscription: { _ in
                    print("Starting Firestore update for user: \(currentUser.uid)")
                },
                receiveOutput: { _ in
                    print("Firestore update successful, updating UserManager")
                    UserManager.shared.updateCurrentUser(updatedUser)
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error updating user data: \(error.localizedDescription)")
                    }
                }
            )
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
