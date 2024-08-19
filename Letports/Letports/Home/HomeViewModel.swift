//
//  HomeViewModel.swift
//  Letports
//
//  Created by 홍준범 on 8/19/24.
//

import Foundation
import UIKit

class HomeViewModel {

    let teamName: String
    let teamIcon: UIImage?
    let homeURL: URL?
    let instaURL: URL?
    let youtubeURL: URL?
    let videoIDs: [String]
    let videoTitles: [String]

    init() {
        // 초기화
        self.teamName = "FC 서울"
        self.teamIcon = UIImage(named: "FCSeoul")
        self.homeURL = URL(string: "http://www.fcseoul.com")
        self.instaURL = URL(string: "https://www.instagram.com/fcseoul")
        self.youtubeURL = URL(string: "https://www.youtube.com/@FCSEOUL")
        self.videoIDs = ["aWp0mk2PEyI", "VM-xTN3Q_9s"]
        self.videoTitles = [
            "줌 인 서울 I 서울의 상승세 어떻게 막을래? I 서울 1-0 인천 I K리그1 2024 R25",
            "줌 인 서울 I 서울의 상승세 어떻게 막을래? I 서울 1-0 인천 I K리그1 2024 R25"
        ]
    }

    func loadThumbnail(for videoID: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error loading image:", error ?? "Unknown error")
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func handleURLTap(for urlType: URLType) -> URL? {
        switch urlType {
        case .home:
            return homeURL
        case .insta:
            return instaURL
        case .youtube:
            return youtubeURL
        }
    }

    enum URLType {
        case home
        case insta
        case youtube
    }
}
