//
//  Team.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Team: Codable {
    var homepage: String
    var instagram: String
    var sportsUID: String
    var teamHomeTown: String
    var teamLogo: String
    var teamName: String
    var teamStadium: String
    var teamStartDate: String
    var teamUID: String
    var youtube: String
    var youtubeChannelID: String
    
    enum CodingKeys: String, CodingKey {
        case homepage = "Homepage"
        case instagram = "Instagram"
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
