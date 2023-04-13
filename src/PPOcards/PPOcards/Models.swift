//
//  BLModels.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import Foundation

struct CardSet: Equatable {
    let id: UUID
    var title: String
    var progress: String
    var color: Int
}

struct Card: Equatable {
    let id: UUID
    let setID: UUID?
    var questionText: String?
    var questionImageURL: URL?
    var answerText: String?
    var answerImageURL: URL?
    var isLearned: Bool
}

struct Settings: Equatable {
    var isMixed: Bool
    var mixingInPower: Int?
}
