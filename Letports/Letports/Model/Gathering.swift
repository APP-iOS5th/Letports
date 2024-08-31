//
//  Gathering.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation
import FirebaseCore

struct SampleGathering1: Codable {
    let gatherImage: String
    let gatherInfo: String
    let gatherMaxMember: Int
    let gatherName: String
    var gatherNowMember: Int
    let gatherQuestion: String
    let gatheringCreateDate: Timestamp
    let gatheringMaster: String
    var gatheringMembers: [SampleMember]
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
//
//  Gathering.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
//import Foundation
//

struct Gathering: Codable {
    let gatherImage: String
    let gatherInfo: String
    let gatherMaxMember: Int
    let gatherName: String
    var gatherNowMember: Int
    let gatherQuestion: String
    let gatheringCreateDate: Timestamp
    let gatheringMaster: String
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
        case gatheringSports = "GatheringSports"
        case gatheringSportsTeam = "GatheringSportsTeam"
        case gatheringUid = "GatheringUid"
    }
}

//snapShot: Optional(["GatheringMaster": users001, "GatherMaxMember": 20, "GatherInfo": 테스트입니다, "GatheringSports": Letports_soccer, "GatherImage": , "GatherNowMember": 3, "GatheringSportsTeam": FCSeoul, "GatherName": 테스트소모임, "GatheringUid": gather004, "GatheringCreateDate": 2024-08-11, "GatherQuestion": 무엇을좋아하나요])
