//
//  CardSetController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import Foundation


class CardSetController: CardSetControllerDescription {
    
    private let dataSource: CardSetRepositoryDescription
    weak var cardController: CardControllerDescription?
    var settings: Settings

    init(dataSource: CardSetRepositoryDescription, settingsController: SettingsControllerDescription) {
        self.dataSource = dataSource
        self.settings = settingsController.getSettings()
        settingsController.cardSetController = self
    }
    
    func getAllCardSets() -> [CardSet] {
        let setIDs = dataSource.getAllCardSetIDs()
        
        var res = [CardSet]()
        
        for setID in setIDs {
            res.append(dataSource.getCardSet(ID: setID)!)
        }
        
        return res
    }

    func getCardSet(ID: UUID) -> CardSet? {
        return dataSource.getCardSet(ID: ID)
    }

    func createCardSet(title: String) -> CardSet {
        let cardSet = CardSet(id: UUID(), title: title, allCardsCount: 0, learnedCardsCount: 0, color: 0xFF0000)

        let _ = dataSource.addCardSet(set: cardSet)

        return cardSet
    }

    func addCard(card: Card, toSet cardSetID: UUID) -> Bool {
        let res = dataSource.addCard(card: card, toSet: cardSetID)
        
        if var set = getCardSet(ID: cardSetID) {
            updateCardSetProgress(cardSetID: cardSetID)
            updateCardSet(oldID: cardSetID, new: set)
        }
        
        return res
    }

    func deleteCardSet(ID: UUID) -> Bool {
        let cardIDs = getAllCardIDsFromSet(from: ID)
        
        for cardID in cardIDs {
            cardController?.deleteCard(ID: cardID)
        }
        
        return dataSource.deleteCardSet(ID: ID)
    }

    func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        dataSource.getLearnedCardIDsFromSet(from: setID)
    }


    func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
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


    func getAllCardIDsFromSet(from setID: UUID) -> [UUID] {
        return dataSource.getAllCardIDsFromSet(setID: setID)
    }

    func updateCardSet(oldID: UUID, new: CardSet) -> Bool {
        return dataSource.updateCardSet(oldID: oldID, newSet: new)
    }

    func updateCardSetProgress(cardSetID: UUID) {
        if var set = getCardSet(ID: cardSetID) {
            set.allCardsCount = getAllCardIDsFromSet(from: cardSetID).count
            set.learnedCardsCount = getLearnedCardIDsFromSet(from: cardSetID).count
            
            updateCardSet(oldID: cardSetID, new: set)
        }
    }
    
}
