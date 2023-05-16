//
//  CardSetRealm.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import RealmSwift

class CardSetRealm: Object {
    @Persisted(primaryKey: true) var _id: UUID
    @Persisted var title: String
    @Persisted var allCardsCount: Int
    @Persisted var learnedCardsCount: Int
    @Persisted var color: Int
    
    convenience init(id: UUID, title: String, allCardsCount: Int, learnedCardsCount: Int, color: Int) throws {
        self.init()

        self._id = id
        self.title = title
        self.allCardsCount = allCardsCount
        self.learnedCardsCount = learnedCardsCount
        self.color = color
    }
}

extension CardSetRealm {
    func convertToCardSet() -> CardSet {
        return CardSet(id: self._id, title: self.title, allCardsCount: self.allCardsCount, learnedCardsCount: self.learnedCardsCount, color: self.color)
    }
}

extension CardSet {
    func convertToCardSetRealm() -> CardSetRealm {
        return try! CardSetRealm(id: self.id, title: self.title, allCardsCount: self.allCardsCount, learnedCardsCount: self.learnedCardsCount, color: self.color)
    }
}
