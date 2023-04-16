//
//  CardController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import Foundation


class CardController: CardControllerDescription {
    private let dataSource: CardRepositoryDescription
    private let cardSetController: CardSetControllerDescription

    init(dataSource: CardRepositoryDescription, cardSetController: CardSetControllerDescription) {
        self.dataSource = dataSource
        self.cardSetController = cardSetController
    }

    func getCard(ID: UUID) -> Card? {
        return dataSource.getCard(ID: ID)
    }

    func createCard(for cardSetID: UUID) -> Card {
        let card = Card(id: UUID(), setID: cardSetID, isLearned: false)

        dataSource.addCard(card: card)
        if var set = cardSetController.getCardSet(ID: cardSetID) {
            set.progress = "\(cardSetController.getAllCardIDsFromSet(from: cardSetID).count - cardSetController.getNotLearnedCardIDsFromSet(from: cardSetID).count)/\(cardSetController.getAllCardIDsFromSet(from: cardSetID).count)"
            cardSetController.updateCardSet(oldID: cardSetID, new: set)
        }

        return card
    }

    func deleteCard(ID: UUID) -> Bool {
        var res = false
        
        if let card = getCard(ID: ID), let cardSetID = card.setID, var set = cardSetController.getCardSet(ID: cardSetID) {
            
            res = dataSource.deleteCard(ID: ID)
            
            set.progress = "\(cardSetController.getAllCardIDsFromSet(from: cardSetID).count - cardSetController.getNotLearnedCardIDsFromSet(from: cardSetID).count)/\(cardSetController.getAllCardIDsFromSet(from: cardSetID).count)"
            cardSetController.updateCardSet(oldID: cardSetID, new: set)
        }
        
        return res
    }

    func updateCard(oldID: UUID, new: Card) -> Bool {
        let res = dataSource.updateCard(oldID: oldID, newCard: new)
        
        if let setId = new.setID, var set = cardSetController.getCardSet(ID: setId) {
            set.progress = "\(cardSetController.getAllCardIDsFromSet(from: setId).count - cardSetController.getNotLearnedCardIDsFromSet(from: setId).count)/\(cardSetController.getAllCardIDsFromSet(from: setId).count)"
            cardSetController.updateCardSet(oldID: setId, new: set)
        }
        
        return res
    }

}
