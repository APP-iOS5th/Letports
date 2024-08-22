//
//  Post.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation

struct Post: Codable {
    let postUID: String
    let userUID: String
    let title: String
    let contents: String
    let imageUrls: [String]
    let comments: [Comment]
    let boardType: String
}
