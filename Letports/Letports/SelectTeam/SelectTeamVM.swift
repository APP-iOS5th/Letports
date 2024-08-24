//
//  SelectTeamVM.swift
//  Letports
//
//  Created by John Yun on 8/24/24.
//

import Foundation
import Combine

class TeamSelectionViewModel {
    struct Category: Hashable, Codable {
        let id: String
        let name: String
    }

    struct Team: Hashable, Codable {
        let id: String
        let name: String
        let logoName: String
        let category: String
    }

    @Published var categories: [Category] = []
    @Published var allTeams: [Team] = []
    @Published var selectedCategory: Category?
    @Published var filteredTeams: [Team] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchCategories()
        fetchTeams()
    }

    func fetchCategories() {
        FirestoreManager.shared.getData(collection: "Categories", document: "categories", type: [Category].self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching categories: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }

    func fetchTeams() {
        FirestoreManager.shared.getData(collection: "Teams", document: "allTeams", type: [Team].self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching teams: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] teams in
                self?.allTeams = teams
                self?.updateFilteredTeams()
            }
            .store(in: &cancellables)
    }

    func selectCategory(_ category: Category) {
        selectedCategory = category
        updateFilteredTeams()
    }

    private func updateFilteredTeams() {
        if let selectedCategory = selectedCategory {
            filteredTeams = allTeams.filter { $0.category == selectedCategory.id }
        } else {
            filteredTeams = allTeams
        }
    }

    func saveUserSelection(userId: String, teamId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreManager.shared.updateData(collection: "Users", document: userId, fields: ["selectedTeamId": teamId])
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .finished:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

//class TeamSelectionViewModel {
//    struct Category: Hashable {
//        let id: String
//        let name: String
//    }
//
//    struct Team: Hashable {
//        let id: String
//        let name: String
//        let logoName: String
//        let category: String
//    }
//
//    var categories: [Category] = [
//        Category(id: "soccer", name: "축구"),
//        Category(id: "baseball", name: "야구"),
//        Category(id: "basketball", name: "농구"),
//        Category(id: "volleyball", name: "배구"),
//        Category(id: "esports", name: "e스포츠")
//    ]
//    
//    var allTeams: [Team] = [
//        Team(id: "fc_seoul", name: "FC서울", logoName: "fc_seoul_logo", category: "soccer"),
//        Team(id: "jeonbuk_hyundai", name: "전북현대", logoName: "jeonbuk_logo", category: "soccer"),
//        Team(id: "jeonbuk_hyundai2", name: "전북현대", logoName: "jeonbuk_logo", category: "soccer"),
//        Team(id: "jeonbuk_hyundai3", name: "전북현대", logoName: "jeonbuk_logo", category: "soccer"),
//        Team(id: "doosan_bears", name: "두산 베어스", logoName: "doosan_logo", category: "baseball"),
//        Team(id: "kt_wiz", name: "KT 위즈", logoName: "kt_logo", category: "baseball"),
//        Team(id: "kt_wiz2", name: "KT 위즈", logoName: "kt_logo", category: "baseball"),
//        Team(id: "kt_wiz3", name: "KT 위즈", logoName: "kt_logo", category: "baseball"),
//        Team(id: "seoul_sk_knights", name: "서울 SK 나이츠", logoName: "sk_knights_logo", category: "basketball"),
//        Team(id: "suwon_kt_sonicboom", name: "수원 KT 소닉붐", logoName: "kt_sonicboom_logo", category: "basketball"),
//        Team(id: "suwon_kt_sonicboom2", name: "수원 KT 소닉붐", logoName: "kt_sonicboom_logo", category: "basketball"),
//        Team(id: "suwon_kt_sonicboom3", name: "수원 KT 소닉붐", logoName: "kt_sonicboom_logo", category: "basketball"),
//        Team(id: "korean_air_jumbos", name: "대한항공 점보스", logoName: "korean_air_logo", category: "volleyball"),
//        Team(id: "hyundai_capital", name: "현대캐피탈 스카이워커스", logoName: "hyundai_capital_logo", category: "volleyball"),
//        Team(id: "hyundai_capital2", name: "현대캐피탈 스카이워커스", logoName: "hyundai_capital_logo", category: "volleyball"),
//        Team(id: "hyundai_capital3", name: "현대캐피탈 스카이워커스", logoName: "hyundai_capital_logo", category: "volleyball"),
//        Team(id: "t1", name: "T1", logoName: "t1_logo", category: "esports"),
//        Team(id: "t12", name: "T1", logoName: "t1_logo", category: "esports"),
//        Team(id: "t13", name: "T1", logoName: "t1_logo", category: "esports"),
//        Team(id: "gen_g", name: "Gen.G", logoName: "geng_logo", category: "esports")
//    ]
//    
//    var selectedCategory: Category?
//    var filteredTeams: [Team] = []
//    
//    func selectCategory(_ category: Category) {
//        selectedCategory = category
//        filteredTeams = allTeams.filter { $0.category == category.id }
//    }
//}
