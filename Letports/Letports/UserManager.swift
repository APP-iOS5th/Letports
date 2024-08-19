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
    
    func login(as role: UserRole) {
        isLoggedIn = true
        userRole = role
    }
    
    func logout() {
        isLoggedIn = false
        userRole = .guest
    }
}
