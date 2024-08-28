//
//  UserManager.swift
//  Letports
//
//  Created by Chung Wussup on 8/7/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    enum UserRole {
        case admin
        case member
        case guest
    }
    
    private(set) var isLoggedIn: Bool = false
    private(set) var userRole: UserRole = .guest
    private(set) var currentUser: LetportsUser?
    
    private init() {}
    
    // userRole을 하면전환화면서
    func login(user: LetportsUser) {
        isLoggedIn = true
        userRole = .guest
        currentUser = user
    }
    
    func logout() {
        isLoggedIn = false
        userRole = .guest
        currentUser = nil
    }
}
