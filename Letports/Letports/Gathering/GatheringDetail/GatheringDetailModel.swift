//
//  GatheringDetailModel.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation

struct GatheringMember {
	var answer: String
	var image: String
	var joinDate: String
	var joinStatus: String
	var nickName: String
	var userUID: String
}

struct BoardPost {
	let postUID: String
	let title: String
	let contents: String
	let boardType: String
	let userUID: String
	let imageUrls: [String]
}

struct Comment {
	// 댓글 구조체 정의
}

struct Gathering {
	var gatherImage: String?
	var gatherName: String?
	var gatherMaxMember: Int?
	var gatherNowMember: Int?
	var gatherInfo: String?
	var gatheringCreateDate: String?
	var gatheringMaster: String?
	var gatheringUid: String?
	var gatheringMembers: [GatheringMember]?
	var gatheringQuestion: String?
}

struct User {
	var UID: String
	var nickName: String
	var image: String
	var email: String
	var myGathering: [String]
	var simpleInfo: String
	var userSports: String
	var userSportsTeam: String
	var answer: String
	var joinDate: String
	var joinStatus: String
}
