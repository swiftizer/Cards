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
    
    var description: String {
        return "  - id: \(id)\n  - title: \(title)\n  - progress: \(progress)\n  - color: \(String(format: "0x%X", color))\n"
    }
}

struct Card: Equatable {
    let id: UUID
    let setID: UUID?
    var questionText: String?
    var questionImageURL: URL?
    var answerText: String?
    var answerImageURL: URL?
    var isLearned: Bool
    
    var description: String {
        return "  - id: \(id)\n  - setID: \(setID!)\n  - questionText: \(questionText ?? " - ")\n  - answerText: \(answerText ?? " - ")\n  - isLearned: \(isLearned)\n"
    }
}

struct Settings: Equatable {
    var isMixed: Bool
    var mixingInPower: Int?
    
    var description: String {
        return "  - isMixed: \(isMixed)\n  - mixingInPower: \(mixingInPower ?? 0)\n"
    }
}
