//
//  CardRealm.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import RealmSwift

class CardRealm: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var setID: UUID?
    @Persisted var questionText: String?
    @Persisted var questionImageURL: Data?
    @Persisted var answerText: String?
    @Persisted var answerImageURL: Data?
    @Persisted var isLearned: Bool
    
    convenience init(id: UUID, setID: UUID?, questionText: String? = nil, questionImageURL: URL? = nil, answerText: String? = nil, answerImageURL: URL? = nil, isLearned: Bool) throws {
        self.init()

        self._id = id
        self.setID = setID
        self.questionText = questionText
        self.questionImageURL = questionImageURL?.dataRepresentation
        self.answerText = answerText
        self.answerImageURL = answerImageURL?.dataRepresentation
        self.isLearned = isLearned
    }
}

extension CardRealm {
    func convertToCard() -> Card {
        return Card(id: self._id, setID: self.setID, questionText: self.questionText, questionImageURL: URL(dataRepresentation: self.questionImageURL ?? Data(), relativeTo: nil), answerText: self.answerText, answerImageURL: URL(dataRepresentation: self.answerImageURL ?? Data(), relativeTo: nil), isLearned: self.isLearned)
    }
}

extension Card {
    func convertToCardRealm() -> CardRealm {
        return try! CardRealm(id: self.id, setID: self.setID, questionText: self.questionText, questionImageURL: self.questionImageURL, answerText: self.answerText, answerImageURL: self.answerImageURL, isLearned: self.isLearned)
    }
}
