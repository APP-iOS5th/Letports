//
//  UserManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/7/24.
//

import Foundation
import Combine
import FirebaseFirestore

class UserManager {
    static let shared = UserManager()
    
    private(set) var isLoggedIn: Bool = false
    private(set) var currentUser: LetportsUser?
    @Published private(set) var selectedTeam: SportsTeam? {
        didSet {
            print("team team", selectedTeam )
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func login(user: LetportsUser) {
        isLoggedIn = true
        currentUser = user
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
    }
    
    func updateCurrentUser(_ user: LetportsUser) {
        currentUser = user
    }
    
    func getUserUid() -> String {
        return currentUser?.uid ?? ""
    }
    
    func getUser() -> LetportsUser {
        guard let user = currentUser else { 
            return LetportsUser(email: "", image: "", nickname: "", simpleInfo: "", uid: "", userSports: "", userSportsTeam: "")}
        return user
    }
    
    func getTeam(completion: @escaping (Result<SportsTeam, FirestoreError>) -> Void) {
        let collectionPath: [FirestorePathComponent] = [
            .collection(.sports),
            .document(getUser().userSports),
            .collection(.sportsTeam),
            .document(getUser().userSportsTeam)
        ]
        
        FM.getData(pathComponents: collectionPath, type: SportsTeam.self)
            .sink { completionResult in
                switch completionResult {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { teams in
                if let team = teams.first {
                    completion(.success(team))
                } else {
                    completion(.failure(.documentNotFound))
                }
            }
            .store(in: &cancellables)
    }
    
    func setTeam(selectTeam: SportsTeam) {
        self.selectedTeam = selectTeam
    }
}
