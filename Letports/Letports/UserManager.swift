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
    
    private init() {}
    
    // userRole을 하면전환화면서
    func login(user: LetportsUser) {
        isLoggedIn = true
        currentUser = user
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
    }
}
