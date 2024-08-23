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
    let gatheringMembers: [SampleGatheringMember]
    let gatheringCreateDate: Date
    let sportsTeam: SampleSportsTeam
    
    enum CodingKeys: String, CodingKey {
        case gatheringSports = "GatheringSports"
        case gatheringTeam = "GatheringSportsTeam"
        case gatheringUID = "GatheringUid"
        case gatheringMaster = "GatheringMaster"
        case gatheringName = "GatherName"
        case gatheringImage = "GatherImage"
        case gatherMaxMember = "GatherMaxMember"
        case gatherNowMember = "GatherNowMember"
        case gatherInfo = "GatherInfo"
        case gatherQuestion = "GatherQuestion"
        case gatheringMembers = "GatheringMembers"
        case gatheringCreateDate = "GatheringCreateDate"
        case sportsTeam = "SportsTeam"
    }
}

struct SampleGatheringMember: Codable {
    let userUID: String
    let nickname: String
    let image: String
    let answer: String
    let joinStatus: String
    let joinDate: Date
    
    enum CodingKeys: String, CodingKey {
        case userUID = "UserUID"
        case nickname = "NickName"
        case image = "Image"
        case answer = "Answer"
        case joinStatus = "JoinStatus"
        case joinDate = "JoinDate"
    }
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

struct SampleSportsTeam: Codable {
    let sportsUID:String
    let teamHomeTown:String
    let teamLogo:String
    let teamName:String
    let teamStadium:String
    let teamStartDate:String
    let teamUID:String
    
    enum CodingKeys: String, CodingKey {
        case sportsUID = "SportsUID"
        case teamHomeTown = "TeamHomeTown"
        case teamLogo = "TeamLogo"
        case teamName = "TeamName"
        case teamStadium = "TeamStadium"
        case teamStartDate = "TeamStartDate"
        case teamUID = "TeamUID"
        
    }
}

//struct User: Codable {
//    let email: String
//    let image: String
//    let myGathering: [String]
//    let nickname: String
//    let simpleInfo: String
//    let uid: String
//    let userSports: String
//    let userSportsTeam: String
//
//    enum CodingKeys: String, CodingKey {
//            case email = "Email"
//            case image = "Image"
//            case myGathering = "MyGathering"
//            case nickname = "NickName"
//            case simpleInfo = "SimpleInfo"
//            case uid = "UID"
//            case userSports = "UserSports"
//            case userSportsTeam = "UserSportsTeam"
//        }
//}
