//
//  CardProgressRealm.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import RealmSwift

class CardProgressRealm: Object {
    @Persisted var cardSetId: UUID
    @Persisted var cardId: UUID
    @Persisted var successCount: Int
    @Persisted var allAttemptsCount: Int
    
    convenience init(cardSetId: UUID, cardId: UUID, successCount: Int, allAttemptsCount: Int) throws {
        self.init()

        self.cardSetId = cardSetId
        self.cardId = cardId
        self.successCount = successCount
        self.allAttemptsCount = allAttemptsCount
    }
}

extension CardProgressRealm {
    func convertToCardSet() -> CardProgress {
        return CardProgress(cardSetId: self.cardSetId, cardId: self.cardId, successCount: self.successCount, allAttemptsCount: self.allAttemptsCount)
    }
}

extension CardProgress {
    func convertToCardSetRealm() -> CardProgressRealm {
        return try! CardProgressRealm(cardSetId: self.cardSetId, cardId: self.cardId, successCount: self.successCount, allAttemptsCount: self.allAttemptsCount)
    }
}
