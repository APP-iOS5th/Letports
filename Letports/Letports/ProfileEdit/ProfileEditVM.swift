//
//  ProfileEditVM.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import Combine
import UIKit

class ProfileEditVM {
    @Published var user: User?
    
    init(user: User?) {
        self.user = user
    }
    
}


