//
//  repositoryInterfaces.swift
//  PPOcards
//
//  Created by Сергей Николаев on 21.03.2023.
//

import Foundation

public protocol CardSetRepositoryDescription {
    func getCardSet(ID: UUID) -> CardSet?
    func addCardSet(set: CardSet) -> Bool
    func getAllCardSets() -> [CardSet]
    func getAllCardIDsFromSet(setID: UUID) -> [UUID]
    func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID]
    func addCard(card: Card, toSet cardSetID: UUID) -> Bool
    func deleteCardSet(ID: UUID) -> Bool
    func deleteAllCardSets()
    func updateCardSet(oldID: UUID, newSet: CardSet) -> Bool
}

public protocol CardRepositoryDescription {
    func getCard(ID: UUID) -> Card?
    func addCard(card: Card) -> Bool
    func updateCard(oldID: UUID, newCard: Card) -> Bool
    func deleteCard(ID: UUID) -> Bool
    func getCardProgress(cardSetID: UUID, cardID: UUID) -> CardProgress?
    func shareCardToSet(cardID: UUID, newSetID: UUID) -> Card?
    func deleteAllCards()
    func markAsLearned(cardID: UUID)
    func markAsNotLearned(cardID: UUID)
}

public protocol SettingsRepositoryDescription {
    func getSettings() -> Settings
    func updateSettings(to newSettings: Settings) -> Bool
}
