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
        cardSetController.updateCardSetProgress(cardSetID: cardSetID)

        return card
    }

    func deleteCard(ID: UUID) -> Bool {
        var res = false
        
        res = dataSource.deleteCard(ID: ID)
        cardSetController.updateCardSetProgress(cardSetID: getCard(ID: ID)?.setID ?? UUID())
        
        return res
    }

    func updateCard(oldID: UUID, new: Card) -> Bool {
        let res = dataSource.updateCard(oldID: oldID, newCard: new)
        cardSetController.updateCardSetProgress(cardSetID: new.setID ?? UUID())
        
        return res
    }

}
