//
//  noticeModel.swift
//  Letports
//
//  Created by Yachae on 8/13/24.
//

import Foundation

struct Board {
	let boardType: String
	let title: String
	let createDate : String // 임시로 String
}

let allBoard = [
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
	Board(boardType: "공지", title: "인원방출", createDate: "2022/09/19"),
]



// 파이어베이스에서 날짜 가져오기
//import Foundation
//import FirebaseFirestore
//
//struct Board {
//	let boardType: String
//	let title: String
//	let createDate: Date
//	let contents: String
//}
//
//// 파이어베이스에서 데이터 가져오기
//let db = Firestore.firestore()
//let documentRef = db.collection("boards").document("documentId")
//
//documentRef.getDocument { (document, error) in
//	if let document = document, document.exists {
//		let boardType = document.get("boardType") as? String
//		let title = document.get("title") as? String
//		let timestamp = document.get("createDate") as? Timestamp
//		let contents = document.get("contents") as? String
//
//		if let createDate = timestamp?.dateValue() {
//			let board = Board(boardType: boardType ?? "", title: title ?? "", createDate: createDate, contents: contents ?? "")
//			// board 변수에 데이터가 할당됨
//		} else {
//			// createDate가 nil일 경우 처리
//		}
//	} else {
//		// 문서가 존재하지 않을 경우 처리
//	}
//}
