//
//  Letports.swift
//  Letports
//
//  Created by mosi on 8/18/24.
//

import Foundation

// User model
struct User: Codable {
    let uid: String
    let nickname: String
    let image: String
    let email: String
    let simpleInfo: String
    let userSports: String
    let userSportsTeam: String
    let myGathering: [String]
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

// Gathering model
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
    let gatheringMembers: [GatheringMember]
    let gatheringCreateDate: Date
}

// GatheringMember model
struct GatheringMember: Codable {
    let userUID: String
    let nickname: String
    let image: String
    let answer: String
    let joinStatus: String
    let joinDate: Date
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
