//
//  CardSetController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import Foundation
import Logger


public class CardSetController: CardSetControllerDescription {
    private let dataSource: CardSetRepositoryDescription
    weak public var cardController: CardControllerDescription?
    public var settings: Settings

    public init(dataSource: CardSetRepositoryDescription, settingsController: SettingsControllerDescription) {
        Logger.shared.log(lvl: .VERBOSE, msg: "CardSetController inited")
        self.dataSource = dataSource
        self.settings = settingsController.getSettings()
        settingsController.cardSetController = self
    }
    
    public func getAllCardSets() -> [CardSet] {
        Logger.shared.log(lvl: .DEBUG, msg: "User gets all card sets")
        let setIDs = dataSource.getAllCardSetIDs()
        
//        var res = [CardSet]()
//        
//        for setID in setIDs {
//            res.append(dataSource.getCardSet(ID: setID)!)
//        }
        
        return setIDs.compactMap { dataSource.getCardSet(ID: $0) }
    }

    public func getCardSet(ID: UUID) -> CardSet? {
        var msg = "User requests to get card set [id=\(ID.uuidString)]: "
        let card = dataSource.getCardSet(ID: ID)
        if card != nil { msg += "Success" } else { msg += "Card not found" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        return card
    }

    public func createCardSet(title: String) -> CardSet {
        let cardSet = CardSet(id: UUID(), title: title, allCardsCount: 0, learnedCardsCount: 0, color: 0xFF0000)
        Logger.shared.log(lvl: .DEBUG, msg: "User creates card set [id=\(cardSet.id.uuidString)] with [title=\(title)]")

        let _ = dataSource.addCardSet(set: cardSet)
        
        return cardSet
    }

    public func addCard(card: Card, toSet cardSetID: UUID) -> Bool {
        let res = dataSource.addCard(card: card, toSet: cardSetID)
        Logger.shared.log(lvl: .DEBUG, msg: "User adds card [id=\(card.id.uuidString)] to card set [id=\(cardSetID.uuidString)]")
        
        if let set = getCardSet(ID: cardSetID) {
            updateCardSetProgress(cardSetID: cardSetID)
            let _ = updateCardSet(oldID: cardSetID, new: set)
        }
        
        return res
    }

    public func deleteCardSet(ID: UUID) -> Bool {
        let cardIDs = getAllCardIDsFromSet(from: ID)
        
        for cardID in cardIDs {
            let _ = cardController?.deleteCard(ID: cardID)
        }
        
        var msg = "User requests to delete card set [id=\(ID.uuidString)]: "
        let res = dataSource.deleteCardSet(ID: ID)
        if res { msg += "Success" } else { msg += "Can not delete card set" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        
        return res
    }

    public func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        Logger.shared.log(lvl: .DEBUG, msg: "User gets learned cards from set [id=\(setID.uuidString)]")
        return dataSource.getLearnedCardIDsFromSet(from: setID)
    }


    public func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        Logger.shared.log(lvl: .DEBUG, msg: "User gets not learned cards from set [id=\(setID.uuidString)]")
        let bufL = dataSource.getLearnedCardIDsFromSet(from: setID).shuffled()
        let bufNL = dataSource.getNotLearnedCardIDsFromSet(from: setID)

        let mixingCount = round(Double(settings.mixingInPower ?? 0) / 100.0 * Double(bufL.count))

        let mixingCards = bufL.prefix(Int(mixingCount))

        var resultArray = bufNL
        var currentIndex = 0

        for elem in mixingCards {
            let randomIndex = Int.random(in: currentIndex...resultArray.count)
            resultArray.insert(elem, at: randomIndex)
            currentIndex = randomIndex + 1
        }
        
        if settings.isMixed {
            return resultArray.shuffled()
        }

        return resultArray
    }


    public func getAllCardIDsFromSet(from setID: UUID) -> [UUID] {
        Logger.shared.log(lvl: .DEBUG, msg: "User gets all cards from set [id=\(setID.uuidString)]")
        return dataSource.getAllCardIDsFromSet(setID: setID)
    }

    public func updateCardSet(oldID: UUID, new: CardSet) -> Bool {
        var msg = "User requests to update card set [id=\(oldID.uuidString)] to new card set [id=\(new.id.uuidString)]: "
        let res = dataSource.updateCardSet(oldID: oldID, newSet: new)
        if res { msg += "Success" } else { msg += "Can not update card set" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        return res
    }

    public func updateCardSetProgress(cardSetID: UUID) {
        Logger.shared.log(lvl: .DEBUG, msg: "Updating progress in card set [id=\(cardSetID.uuidString)]")
        if var set = getCardSet(ID: cardSetID) {
            set.allCardsCount = getAllCardIDsFromSet(from: cardSetID).count
            set.learnedCardsCount = getLearnedCardIDsFromSet(from: cardSetID).count
            let red = (255 - 255 * set.learnedCardsCount / (set.allCardsCount == 0 ? 1 : set.allCardsCount)) << 16
            let green = (255 - (red >> 16)) << 8
            set.color = red + green

            let _ = updateCardSet(oldID: cardSetID, new: set)
        }
    }
    
    public func deleteAllCardSets() {
        dataSource.deleteAllCardSets()
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "CardSetController deinited")
    }
}
