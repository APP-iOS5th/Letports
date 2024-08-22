//
//  GatheringDetailModel.swift
//  Letports
//
//  Created by Yachae on 8/22/24.
//

import Foundation


struct BoardPost {
	var boardType: String
	var comments: [Comment]?
	var contents: String
	var imageUrls: [String]?
	var postUID: String
	var title: String
	var userUID: String
}


struct LeportsUser {
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
