//
//  CardController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import UIKit


class CardController: CardControllerDescription {
    private let dataSource: CardRepositoryDescription

    init(dataSource: CardRepositoryDescription) {
        self.dataSource = dataSource
    }

    func getCard(ID: UUID) -> Card? {
        return dataSource.getCard(ID: ID)
    }

    func createCard(for cardSetID: UUID) -> Card {
        let card = Card(id: UUID(), setID: cardSetID, isLearned: false)

        dataSource.addCard(card: card)

        return card
    }

    func deleteCard(ID: UUID) -> Bool {
        return dataSource.deleteCard(ID: ID)
    }

    func updateCard(oldID: UUID, new: Card) -> Bool {
        return dataSource.updateCard(oldID: oldID, newCard: new)
    }

}
