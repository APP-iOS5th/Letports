//
//  Team.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Sports: Hashable, Codable {
    let id: String
    let name: String
    let sportsUID: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.sportsUID = try container.decode(String.self, forKey: .sportsUID)

        self.id = self.sportsUID.replacingOccurrences(of: "Letports_", with: "")
    }

    private enum CodingKeys: String, CodingKey {
        case name = "SportsName"
        case sportsUID = "SportsUID"
    }
}


struct SportsTeam: Hashable, Codable {
    let homepage: String
    let instagram: String
    let sportsUID: String
    let sportsName: String
    let shortName: String
    let logoHex: String
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
        case teamHomeTown = "TeamHomeTown"
        case teamLogo = "TeamLogo"
        case teamName = "TeamName"
        case teamStadium = "TeamStadium"
        case shortName = "ShortName"
        case logoHex = "LogoHex"
        case teamStartDate = "TeamStartDate"
        case teamUID = "TeamUID"
        case youtube = "Youtube"
        case youtubeChannelID = "YoutubeChannelID"
    }
}
