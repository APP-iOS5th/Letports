//
//  Gathering.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Gathering: Codable {
    let gatherImage: String
    let gatherInfo: String
    let gatherMaxMember: Int
    let gatherName: String
    var gatherNowMember: Int
    let gatherQuestion: String
    let gatheringCreateDate: String
    let gatheringMaster: String
    var gatheringMembers: [GatheringMember]
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
