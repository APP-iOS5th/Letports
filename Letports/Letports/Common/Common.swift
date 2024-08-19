//
//  Common.swift
//  Letports
//
//  Created by Chung Wussup on 8/19/24.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

let FM = FirestoreManager.shared
let STOREAGE = Storage.storage()
let FIRESTORE = Firestore.firestore()


struct Gathering: Codable {
    let gatheringSports: String
    let gatheringTeam: String
    let gatheringUID: String
    let gatheringMaster: String
    let gatheringName: String
    let gatheringImage: String
    let gatherMaxMember: Int
    let gatherNowMember: Int
    let gatherInfo: String
    let gatherQuestion: String
//    let gatheringMembers: [GatheringMember]
    let gatheringMembers: [String]
    let gatheringCreateDate: Date
}

struct GatheringMember: Codable {
    let userUID: String
    let nickname: String
    let image: String
    let answer: String
    let joinStatus: String
    let joinDate: Date
}
