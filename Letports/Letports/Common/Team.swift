//
//  Team.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Team: Codable {
    let teamUID: String
    let teamName: String
    let teamLogo: String
    let teamSns: [String: String]
    let teamHomeTown: String
    let teamStadium: String
    let teamStartDate: String
}
