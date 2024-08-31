//
//  Team.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct SportsTeam: Codable {
    let homepage: String
    let instagram: String
    let sportsUID: String
    let sportsName: String
    let sportsUID: String
    let teamHomeTown: String
    let teamLogo: String
    let teamName: String
    let teamStadium: String
    let teamStartDate: String
    let teamUID: String
    let youtube: String
    let youtubeChannelID: String

    enum CodingKeys: String, CodingKey {
        case homepage = "Homepage"
        case instagram = "Instagram"
        case sportsUID = "SportsUID"
        case sportsName = "SportsName"
        case sportsUID = "SportsUID"
        case teamHomeTown = "TeamHomeTown"
        case teamLogo = "TeamLogo"
        case teamName = "TeamName"
        case teamStadium = "TeamStadium"
        case teamStartDate = "TeamStartDate"
        case teamUID = "TeamUID"
        case youtube = "Youtube"
        case youtubeChannelID = "YoutubeChannelID"
    }
}
