//
//  BLModels.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import UIKit

struct CardSet: Equatable {
    let id: UUID
    var title: String
    var progress: String
    var color: UIColor
}

struct Card: Equatable {
    let id: UUID
    let setID: UUID?
    var questionText: String?
    var questionImage: UIImage?
    var answerText: String?
    var answerImage: UIImage?
    var isLearned: Bool
}

struct Settings: Equatable {
    var isMixed: Bool
    var mixingInPower: Int?
}
