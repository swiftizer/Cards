//
//  RealmCardSetRepository.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import RealmSwift
import Core


public class RealmCardSetRepository: CardSetRepositoryDescription {
    
    let realm = try! Realm()
    
    public init() {}
    
    public func getCardSet(ID: UUID) -> Core.CardSet? {
        let cardSetRealm = realm.objects(CardSetRealm.self).where {
            $0._id == ID
        }.first

        if let cardSetRealm = cardSetRealm {
            return cardSetRealm.convertToCardSet()
        }
        
        return nil
    }
    
    public func addCardSet(set: Core.CardSet) -> Bool {
        let realmCardSet = set.convertToCardSetRealm()
        
        do {
            try realm.write {
                realm.add(realmCardSet)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func getAllCardSetIDs() -> [UUID] {
        let cardSetsRealm = realm.objects(CardSetRealm.self)
        
        return cardSetsRealm.map { $0._id }
    }
    
    public func getAllCardIDsFromSet(setID: UUID) -> [UUID] {
        let cardsRealm = realm.objects(CardRealm.self).where {
            $0.setID == setID
        }

        return cardsRealm.map { $0._id }
    }
    
    public func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let cardsRealm = realm.objects(CardRealm.self).where {
            $0.setID == setID && $0.isLearned == false
        }

        return cardsRealm.map { $0._id }
    }
    
    public func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let cards = realm.objects(CardRealm.self).where {
            $0.setID == setID && $0.isLearned == true
        }

        return cards.map { $0._id }
    }
    
    public func addCard(card: Core.Card, toSet cardSetID: UUID) -> Bool {
        var cardMod = Card(id: card.id, setID: cardSetID, questionText: card.questionText, questionImageURL: card.questionImageURL, answerText: card.answerText, answerImageURL: card.answerImageURL, isLearned: card.isLearned)
        
        let realmCard = cardMod.convertToCardRealm()
        
        do {
            try realm.write {
                realm.add(realmCard)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func deleteCardSet(ID: UUID) -> Bool {
        let cardSetRealm = realm.objects(CardSetRealm.self).where {
            $0._id == ID
        }.first
        
        guard let cardSetRealm = cardSetRealm else { return false }
        
        do {
            try realm.write {
                realm.delete(cardSetRealm)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func deleteAllCardSets() {
        let cardSetsRealm = realm.objects(CardSetRealm.self)
        
        try! realm.write {
            realm.delete(cardSetsRealm)
        }
    }
    
    public func updateCardSet(oldID: UUID, newSet: Core.CardSet) -> Bool {
        var cardSetRealm = realm.objects(CardSetRealm.self).where {
            $0._id == oldID
        }.first
        
        do {
            try realm.write {
                cardSetRealm?.title = newSet.title
                cardSetRealm?.allCardsCount = newSet.allCardsCount
                cardSetRealm?.learnedCardsCount = newSet.learnedCardsCount
                cardSetRealm?.color = newSet.color
            }
        } catch {
            return false
        }
        
        return true
    }
}
