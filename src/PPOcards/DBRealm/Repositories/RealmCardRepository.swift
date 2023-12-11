//
//  RealmCardRepository.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import RealmSwift
import Core


public class RealmCardRepository: CardRepositoryDescription {
    
    let realm = try! Realm()
    
    public init() {}
    
    public func getCard(ID: UUID) -> Core.Card? {
        let cardRealm = realm.objects(CardRealm.self).where {
            $0._id == ID
        }.first

        if let cardRealm = cardRealm {
            return cardRealm.convertToCard()
        }
        
        return nil
    }
    
    public func addCard(card: Core.Card) -> Bool {
        let realmCard = card.convertToCardRealm()
        
        do {
            try realm.write {
                realm.add(realmCard)
                realm.add(try CardProgressRealm(cardSetId: card.setID ?? UUID(), cardId: card.id, successCount: 0, allAttemptsCount: 0))
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func updateCard(oldID: UUID, newCard: Core.Card) -> Bool {
        var cardRealm = realm.objects(CardRealm.self).where {
            $0._id == oldID
        }.first
        
        let newCardRealm = newCard.convertToCardRealm()
        
        do {
            try realm.write {
                cardRealm?.setID = newCardRealm.setID
                cardRealm?.questionText = newCardRealm.questionText
                cardRealm?.questionImageURL = newCardRealm.questionImageURL
                cardRealm?.answerText = newCardRealm.answerText
                cardRealm?.answerImageURL = newCardRealm.answerImageURL
                cardRealm?.isLearned = newCardRealm.isLearned
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func deleteCard(ID: UUID) -> Bool {
        let card = realm.objects(CardRealm.self).where {
            $0._id == ID
        }.first
        
        guard let card = card else { return false }
        
        do {
            try realm.write {
                realm.delete(card)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func getCardProgress(cardSetID: UUID, cardID: UUID) -> Core.CardProgress? {
        let cardProgress = realm.objects(CardProgressRealm.self).where {
            $0.cardSetId == cardSetID && $0.cardId == cardID
        }.first

        if let cardProgress = cardProgress {
            return cardProgress.convertToCardSet()
        }
        
        return nil
    }
    
    public func shareCardToSet(cardID: UUID, newSetID: UUID) -> Bool {
        guard let card = getCard(ID: cardID) else { return false }
        
        return addCard(card: Card(id: UUID(), setID: newSetID, questionText: card.questionText, questionImageURL: card.questionImageURL, answerText: card.answerText, answerImageURL: card.answerImageURL, isLearned: false))
    }
    
    public func deleteAllCards() {
        let cards = realm.objects(CardRealm.self)
        
        try! realm.write {
            realm.delete(cards)
        }
    }
    
    public func markAsLearned(cardID: UUID) {
        guard var card = getCard(ID: cardID) else { return }
        
        card.isLearned = true
        let _ = updateCard(oldID: cardID, newCard: card)
        
        let cardProgress = realm.objects(CardProgressRealm.self).where {
            $0.cardSetId == card.setID ?? UUID() && $0.cardId == card.id
        }.first
        
        try! realm.write {
            cardProgress?.allAttemptsCount += 1
            cardProgress?.successCount += 1
        }
    }
    
    public func markAsNotLearned(cardID: UUID) {
        guard var card = getCard(ID: cardID) else { return }
        
        card.isLearned = false
        let _ = updateCard(oldID: cardID, newCard: card)
        
        let cardProgress = realm.objects(CardProgressRealm.self).where {
            $0.cardSetId == card.setID ?? UUID() && $0.cardId == card.id
        }.first
        
        try! realm.write {
            cardProgress?.allAttemptsCount += 1
        }
    }
}
