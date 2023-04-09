//
//  CardSetController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import UIKit


class CardSetController: CardSetControllerDescription {
    private let dataSource: CardSetRepositoryDescription
    var settings: Settings

    init(dataSource: CardSetRepositoryDescription, settingsController: SettingsControllerDescription) {
        self.dataSource = dataSource
        self.settings = settingsController.getSettings()
        settingsController.cardSetController = self
    }

    func getCardSet(ID: UUID) -> CardSet? {
        return dataSource.getCardSet(ID: ID)
    }

    func createCardSet(title: String) -> CardSet {
        let cardSet = CardSet(id: UUID(), title: title, progress: "0/0", color: .red)

        dataSource.addCardSet(set: cardSet)

        return cardSet
    }

    func addCard(card: Card, toSet cardSetID: UUID) -> Bool {
        return dataSource.addCard(card: card, toSet: cardSetID)
    }

    func deleteCardSet(ID: UUID) -> Bool {
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

        return resultArray
    }


    func getAllCardIDsFromSet(from setID: UUID) -> [UUID] {
        let cardIDs = dataSource.getAllCardIDsFromSet(setID: setID)
        if settings.isMixed {
            return cardIDs.shuffled()
        }
        return cardIDs
    }

    func updateCardSet(oldID: UUID, new: CardSet) -> Bool {
        return dataSource.updateCardSet(oldID: oldID, newSet: new)
    }


}
