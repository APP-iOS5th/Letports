//
//  GatheringMebmer.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct SampleMember: Codable {
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
        case userUID = "UserUid"
        case simpleInfo = "SimpleInfo"
    }
}

struct GatheringMember: Codable {
	let answer: String
	let joinDate: String
	let joinStatus: String
	let userUID: String

	enum CodingKeys: String, CodingKey {
		case answer = "Answer"
		case joinDate = "JoinDate"
		case joinStatus = "JoinStatus"
		case userUID = "UserUid"
	}
}
