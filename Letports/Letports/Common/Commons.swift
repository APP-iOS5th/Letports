//
//  Commons.swift
//  Letports
//
//  Created by mosi on 8/20/24.
//
import Foundation

// User model
struct User: Codable {
    let email: String
    let image: String
    let myGathering: [String]
    let nickname: String
    let simpleInfo: String
    let uid: String
    let userSports: String
    let userSportsTeam: String

    enum CodingKeys: String, CodingKey {
            case email = "Email"
            case image = "Image"
            case myGathering = "MyGathering"
            case nickname = "NickName"
            case simpleInfo = "SimpleInfo"
            case uid = "UID"
            case userSports = "UserSports"
            case userSportsTeam = "UserSportsTeam"
        }
}



// Sports model
struct Sports: Codable {
    let sportsUID: String
    let sportsName: String
}

// Team model
struct Team: Codable {
    let teamUID: String
    let teamName: String
    let teamLogo: String
    let teamSns: [String: String]
    let teamHomeTown: String
    let teamStadium: String
    let teamStartDate: String
}

struct Gathering: Codable {
    let gatherImage: String
    let gatherInfo: String
    let gatherMaxMember: Int
    let gatherName: String
    let gatherNowMember: Int
    let gatherQuestion: String
    let gatheringCreateDate: String
    let gatheringMaster: String
    let gatheringMembers: [GatheringMember]
    let gatheringSports: String
    let gatheringSportsTeam: String
    let gatheringUid: String

    enum CodingKeys: String, CodingKey {
        case gatherImage = "GatherImage"
        case gatherInfo = "GatherInfo"
        case gatherMaxMember = "GatherMaxMember"
        case gatherName = "GatherName"
        case gatherNowMember = "GatherNowMember"
        case gatherQuestion = "GatherQuestion"
        case gatheringCreateDate = "GatheringCreateDate"
        case gatheringMaster = "GatheringMaster"
        case gatheringMembers = "GatheringMembers"
        case gatheringSports = "GatheringSports"
        case gatheringSportsTeam = "GatheringSportsTeam"
        case gatheringUid = "GatheringUid"
    }
}

// MARK: - GatheringMember
struct GatheringMember: Codable {
    let answer: String
    let image: String
    let joinDate: String
    let joinStatus: String
    let nickName: String
    let userUID: String
    let simpleInfo: String
    enum CodingKeys: String, CodingKey {
        case answer = "Answer"
        case image = "Image"
        case joinDate = "JoinDate"
        case joinStatus = "JoinStatus"
        case nickName = "NickName"
        case userUID = "UserUID"
        case simpleInfo = "SimpleInfo"
    }
}

// Comment model
struct Comment: Codable {
    let postUID: String
    let commentUID: String
    let userUID: String
    let contents: String
    let createDate: Date
    let writeDate: Date
}

// Post model
struct Post: Codable {
    let postUID: String
    let userUID: String
    let title: String
    let contents: String
    let imageUrls: [String]
    let comments: [Comment]
    let boardType: String
}
