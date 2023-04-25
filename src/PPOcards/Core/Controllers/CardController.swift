//
//  CardController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import Foundation
import Logger


public class CardController: CardControllerDescription {
    private let dataSource: CardRepositoryDescription
    private let cardSetController: CardSetControllerDescription

    public init(dataSource: CardRepositoryDescription, cardSetController: CardSetControllerDescription) {
        Logger.shared.log(lvl: .VERBOSE, msg: "CardController inited")
        self.dataSource = dataSource
        self.cardSetController = cardSetController
    }

    public func getCard(ID: UUID) -> Card? {
        var msg = "User requests to get card [id=\(ID.uuidString)]: "
        let card = dataSource.getCard(ID: ID)
        if card != nil { msg += "Success" } else { msg += "Card not found" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        return card
    }

    public func createCard(for cardSetID: UUID) -> Card {
        let card = Card(id: UUID(), setID: cardSetID, isLearned: false)
        Logger.shared.log(lvl: .DEBUG, msg: "User creates card [id=\(card.id.uuidString)] for card set [id=\(cardSetID.uuidString)]")

        dataSource.addCard(card: card)
        cardSetController.updateCardSetProgress(cardSetID: cardSetID)

        return card
    }

    public func deleteCard(ID: UUID) -> Bool {
        var msg = "User requests to delete card [id=\(ID.uuidString)]: "
        let res = dataSource.deleteCard(ID: ID)
        if res { msg += "Success" } else { msg += "Can not delete card" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: getCard(ID: ID)?.setID ?? UUID())
        
        return res
    }

    public func updateCard(oldID: UUID, new: Card) -> Bool {
        var msg = "User requests to update card [id=\(oldID.uuidString)] to new card [id=\(new.id.uuidString)]: "
        let res = dataSource.updateCard(oldID: oldID, newCard: new)
        if res { msg += "Success" } else { msg += "Can not update card" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: new.setID ?? UUID())
        
        return res
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "CardController deinited")
    }

}
