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



//MARK: - Sample Models 추후 삭제 필요
struct SampleGathering: Codable {
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

struct SampleGatheringMember: Codable {
    let userUID: String
    let nickname: String
    let image: String
    let answer: String
    let joinStatus: String
    let joinDate: Date
}

// Post model
struct SamplePost: Codable {
    let postUID: String
    let userUID: String
    let title: String
    let contents: String
    let imageUrls: [String]
    let comments: [SampleComment]
    let boardType: String
}

// Comment model
struct SampleComment: Codable {
    let postUID: String
    let commentUID: String
    let userUID: String
    let contents: String
    let createDate: Date
    let writeDate: Date
}


