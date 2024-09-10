//
//  Post.swift
//  Letports
//
//  Created by mosi on 8/22/24.
//
import Foundation
import FirebaseCore

enum PostType: String, Codable {
	case all
	case free
	case noti
	
	var title: String {
		switch self {
		case .all:
			return "전체"
		case .free:
			return "자유게시판"
		case .noti:
			return "공지"
		}
	}
}

struct Post: Codable {
    let postUID: String
    let userUID: String
    let title: String
    let contents: String
    let imageUrls: [String]
    let boardType: PostType
    let createDate: Timestamp
}
