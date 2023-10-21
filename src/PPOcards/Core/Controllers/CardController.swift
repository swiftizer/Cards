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

        let _ = dataSource.addCard(card: card)
        cardSetController.updateCardSetProgress(cardSetID: cardSetID)

        return card
    }

    public func deleteCard(ID: UUID) -> Bool {
        var msg = "User requests to delete card [id=\(ID.uuidString)]: "
        let setID = getCard(ID: ID)?.setID
        let res = dataSource.deleteCard(ID: ID)
        if res { msg += "Success" } else { msg += "Can not delete card" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: setID ?? UUID())
        
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
    
    public func deleteAllCards() {
        dataSource.deleteAllCards()
    }
    
    public func getCardProgress(cardSetID: UUID, cardID: UUID) -> CardProgress? {
        var msg = "User requests to get cardProgress [cardSetID=\(cardSetID.uuidString), cardID=\(cardID.uuidString)]: "
        let cardProgress = dataSource.getCardProgress(cardSetID: cardSetID, cardID: cardID)
        if cardProgress != nil { msg += "Success" } else { msg += "cardProgress not found" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        return cardProgress
    }
    
    public func shareCardToSet(cardID: UUID, newSetID: UUID) -> Bool {
        var msg = "User requests to share card [cardID=\(cardID.uuidString)] to set [newSetID=\(newSetID.uuidString)]: "
        let res = dataSource.shareCardToSet(cardID: cardID, newSetID: newSetID)
        if res { msg += "Success" } else { msg += "sharing faild" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: newSetID)
        
        return res
    }
    
    public func markAsLearned(cardID: UUID) {
        var msg = "User marks card [id=\(cardID.uuidString)] as learned"
        dataSource.markAsLearned(cardID: cardID)
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: getCard(ID: cardID)?.setID ?? UUID())
    }
    
    public func markAsNotLearned(cardID: UUID) {
        var msg = "User marks card [id=\(cardID.uuidString)] as not learned"
        dataSource.markAsNotLearned(cardID: cardID)
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        cardSetController.updateCardSetProgress(cardSetID: getCard(ID: cardID)?.setID ?? UUID())
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "CardController deinited")
    }
}
