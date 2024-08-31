//
//  UserManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/7/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private(set) var isLoggedIn: Bool = false
    private(set) var currentUser: LetportsUser?
    private(set) var selectedTeam: Team?
    
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
    
    func getTeam() -> Team {
        guard let team = selectedTeam else {
            return Team(homepage: "", instagram: "", sportsName: "", teamHomeTown: "", teamLogo: "", teamName: "", teamStadium: "", teamStartDate: "", teamUID: "", youtube: "", youtubeChannelID: "")
        }
        return team
    }
}
