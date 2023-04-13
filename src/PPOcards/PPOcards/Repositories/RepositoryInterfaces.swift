//
//  repositoryInterfaces.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import Foundation

protocol CardSetRepositoryDescription {
    func getCardSet(ID: UUID) -> CardSet?
    func addCardSet(set: CardSet) -> Bool
    func getAllCardSetIDs() -> [UUID]
    func getAllCardIDsFromSet(setID: UUID) -> [UUID]
    func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func addCard(card: Card, toSet cardSetID: UUID) -> Bool
    func deleteCardSet(ID: UUID) -> Bool
    func updateCardSet(oldID: UUID, newSet: CardSet) -> Bool
}

protocol CardRepositoryDescription {
    func getCard(ID: UUID) -> Card?
    func addCard(card: Card) -> Bool
    func updateCard(oldID: UUID, newCard: Card) -> Bool
    func deleteCard(ID: UUID) -> Bool
}

protocol SettingsRepositoryDescription {
    func createSettings() -> Bool
    func getSettings() -> Settings
    func updateSettings(to newSettings: Settings) -> Bool
}
