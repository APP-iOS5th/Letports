//
//  Post.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

enum PostType: String, Codable {
    case all
    case free
    case noti
}

struct Post: Codable {
    let postUID: String
    let userUID: String
    let title: String
    let contents: String
    let imageUrls: [String]
    let boardType: String
}
