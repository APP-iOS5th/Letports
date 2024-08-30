//
//  Comment.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Comment: Codable {
    let postUID: String
    let commentUID: String
    let userUID: String
    let contents: String
    let createDate: String
}
