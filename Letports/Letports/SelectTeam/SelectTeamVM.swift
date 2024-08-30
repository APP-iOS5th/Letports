//
//  SelectTeamVM.swift
//  Letports
//
//  Created by John Yun on 8/24/24.
//

import Foundation
import Combine
import Kingfisher


class TeamSelectionViewModel {
    struct Sports: Hashable, Codable {
        let id: String
        let name: String
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
    
    private var cancellables = Set<AnyCancellable>()
    
    func selectSports(_ sports: Sports) {
        selectedSports = sports
        filteredTeams = allTeams.filter { $0.sports == sports.id }
    }
    
    func loadData(completion: @escaping () -> Void) {
        print("TeamSelectionViewModel - loadData called")
        
        loadSportsCategories { [weak self] in
            self?.loadAllTeams {
                print("All data loaded")
                completion()
            }
        }
    }
    
    private func loadSportsCategories(completion: @escaping () -> Void) {
        print("TeamSelectionViewModel - loadSportsCategories started")
        
        FirestoreManager.shared.getSportsCategories()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading sports categories: \(error)")
                }
            }, receiveValue: { [weak self] sportsCategories in
                print("Received sports categories: \(sportsCategories.count)")
                self?.sportsCategories = sportsCategories
                completion()
            })
            .store(in: &cancellables)
    }
    
    private func loadAllTeams(completion: @escaping () -> Void) {
        Publishers.MergeMany(sportsCategories.map { sports in
            FirestoreManager.shared.getTeamsForSports(sports.id)
        })
        .collect()
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error loading teams: \(error)")
            }
        }, receiveValue: { [weak self] teamsArray in
            print("Received teams: \(teamsArray.flatMap { $0 }.count)")
            self?.allTeams = teamsArray.flatMap { $0 }
            completion()
        })
        .store(in: &cancellables)
    }
}

extension TeamSelectionViewModel {
    func updateUserSportsAndTeam(sports: Sports, team: Team) -> AnyPublisher<Void, Error> {
        guard let currentUser = UserManager.shared.currentUser else {
            return Fail(error: NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user found"])).eraseToAnyPublisher()
        }
        
        let updatedUser = LetportsUser(
            email: currentUser.email,
            image: currentUser.image,
            nickname: currentUser.nickname,
            simpleInfo: currentUser.simpleInfo,
            uid: currentUser.uid,
            userSports: sports.id,
            userSportsTeam: team.teamUID
        )
        
        return FM.updateData(collection: "Users", document: currentUser.uid, data: updatedUser)
            .mapError { $0 as Error }
            .flatMap { _ -> AnyPublisher<Void, Error> in
                UserManager.shared.updateCurrentUser(updatedUser)
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
