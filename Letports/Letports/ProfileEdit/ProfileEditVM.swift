//
//  ProfileEditVM.swift
//  Letports
//
//  Created by mosi on 8/19/24.
//

import Combine
import UIKit

class ProfileEditVM {
    @Published var user: LetportsUser?
    
    init(user: LetportsUser?) {
        self.user = user
    }
    
}


