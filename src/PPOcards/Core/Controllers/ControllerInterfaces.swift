//
//  controllerInterfaces.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import Foundation

public protocol CardSetControllerDescription: AnyObject {
    var settings: Settings { get set }
    func getAllCardSets() -> [CardSet]
    func getCardSet(ID: UUID) -> CardSet?
    func createCardSet(title: String) -> CardSet
    func addCard(card: Card, toSet cardSet: UUID) -> Bool
    func getAllCardIDsFromSet(from setID: UUID) -> [UUID]
    func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func updateCardSet(oldID: UUID, new: CardSet) -> Bool
    func deleteCardSet(ID: UUID) -> Bool
    func deleteAllCardSets()
    func updateCardSetProgress(cardSetID: UUID)
}

public protocol CardControllerDescription: AnyObject {
    func getCard(ID: UUID) -> Card?
    func createCard(for cardSetID: UUID) -> Card
    func updateCard(oldID: UUID, new: Card) -> Bool
    func deleteCard(ID: UUID) -> Bool
    func deleteAllCards()
}

public protocol SettingsControllerDescription: AnyObject {
    var cardSetController: CardSetControllerDescription? { get set }
    func getSettings() -> Settings
    func updateSettings(to newSettings: Settings) -> Bool
}
