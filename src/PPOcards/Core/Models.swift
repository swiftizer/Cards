//
//  BLModels.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import Foundation

public struct CardSet: Codable {
    public let id: UUID
    public var title: String
    public var allCardsCount: Int
    public var learnedCardsCount: Int
    public var color: Int
    
    public init(id: UUID, title: String, allCardsCount: Int, learnedCardsCount: Int, color: Int) {
        self.id = id
        self.title = title
        self.allCardsCount = allCardsCount
        self.learnedCardsCount = learnedCardsCount
        self.color = color
    }

    enum CodingKeys: String, CodingKey {
        case id = "card_set_id"
        case title
        case allCardsCount = "all_cards_count"
        case learnedCardsCount = "learned_cards_count"
        case color
    }

    public var description: String {
        return "  - id: \(id)\n  - title: \(title)\n  - progress: \(learnedCardsCount)/\(allCardsCount)\n  - color: \(String(format: "0x%X", color))\n"
    }
}

public struct Card: Codable {
    public let id: UUID
    public let setID: UUID?
    public var questionText: String?
    public var questionImageURL: URL?
    public var answerText: String?
    public var answerImageURL: URL?
    public var isLearned: Bool
    
    public init(id: UUID, setID: UUID?, questionText: String? = nil, questionImageURL: URL? = nil, answerText: String? = nil, answerImageURL: URL? = nil, isLearned: Bool) {
        self.id = id
        self.setID = setID
        self.questionText = questionText
        self.questionImageURL = questionImageURL
        self.answerText = answerText
        self.answerImageURL = answerImageURL
        self.isLearned = isLearned
    }

    enum CodingKeys: String, CodingKey {
        case id = "card_id"
        case setID = "card_set_id"
        case questionText = "question_text"
        case questionImageURL = "question_image"
        case answerText = "answer_text"
        case answerImageURL = "answer_image"
        case isLearned = "is_learned"
    }

    public var description: String {
        return "  - id: \(id)\n  - setID: \(setID!)\n  - questionText: \(questionText ?? " - ")\n  - answerText: \(answerText ?? " - ")\n  - isLearned: \(isLearned)\n"
    }
}

public struct Settings: Codable {
    public var isMixed: Bool
    public var mixingInPower: Int?
    
    public init(isMixed: Bool, mixingInPower: Int? = nil) {
        self.isMixed = isMixed
        self.mixingInPower = mixingInPower
    }

    enum CodingKeys: String, CodingKey {
        case isMixed = "is_mixed"
        case mixingInPower = "mixing_in_power"
    }

    public var description: String {
        return "  - isMixed: \(isMixed)\n  - mixingInPower: \(mixingInPower ?? 0)\n"
    }
    
    public var logDescription: String {
        return "- isMixed: \(isMixed); - mixingInPower: \(mixingInPower ?? 0)"
    }
}

public struct CardProgress: Equatable {
    public var cardSetId: UUID
    public var cardId: UUID
    public var successCount: Int
    public var allAttemptsCount: Int
    
    public init(cardSetId: UUID, cardId: UUID, successCount: Int, allAttemptsCount: Int) {
        self.cardSetId = cardSetId
        self.cardId = cardId
        self.successCount = successCount
        self.allAttemptsCount = allAttemptsCount
    }
    
    public var logDescription: String {
        return "- cardSetId: \(cardSetId); - cardId: \(cardId); - successCount: \(successCount); - allAttemptsCount: \(allAttemptsCount)"
    }
}
