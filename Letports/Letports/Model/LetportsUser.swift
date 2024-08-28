//
//  User.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct LetportsUser: Codable {
    let email: String
    let image: String
    let myGathering: [String] = ["레포츠"]
    let nickname: String
    let simpleInfo: String
    let uid: String
    let userSports: String
    let userSportsTeam: String
    
    enum CodingKeys: String, CodingKey {
        case email = "Email"
        case image = "Image"
        case nickname = "NickName"
        case simpleInfo = "SimpleInfo"
        case uid = "UID"
        case userSports = "UserSports"
        case userSportsTeam = "UserSportsTeam"
    }
}
