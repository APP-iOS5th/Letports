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

    @Published var sportsCategories: [Sports] = []
    @Published var allTeams: [SportsTeam] = []
    @Published var filteredTeams: [SportsTeam] = []
    @Published var selectedSports: Sports?
    @Published var selectedTeam: SportsTeam?
    
    private var cancellables = Set<AnyCancellable>()
    
    func selectSports(_ sports: Sports) {
        selectedSports = sports
        selectedTeam = nil
        filteredTeams = allTeams.filter { $0.sportsUID == sports.sportsUID }
    }
    
    func selectTeam(_ team: SportsTeam?) {
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
        let collectionPath: [FirestorePathComponent] = [
            .collection(.sports)
        ]
        
        FM.getData(pathComponents: collectionPath, type: Sports.self)
            .sink { _ in
            } receiveValue: { sports in
                self.sportsCategories = sports
                completion()
            }
            .store(in: &cancellables)

    }
    
    private func loadAllTeams(completion: @escaping () -> Void) {
        Publishers.MergeMany(sportsCategories.map { sports in
            let collectionPath: [FirestorePathComponent] = [
                .collection(.sports),
                .document(sports.sportsUID),
                .collection(.sportsTeam)]
            
                return FM.getData(pathComponents: collectionPath, type: SportsTeam.self)
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
    func updateUserSportsAndTeam(sports: Sports, team: SportsTeam) -> AnyPublisher<Void, Error> {
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
