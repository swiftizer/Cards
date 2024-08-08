//
//  CoreDataCardSetRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import FileManager
import Core


public class CoreDataCardSetRepository: CardSetRepositoryDescription {

    private let coreDataManager: CoreDataManagerDescription!
    private let fileManager = MyFileManager.shared

    public init() {
        coreDataManager = CoreDataManager.shared
    }

    public init(customDataManager: CoreDataManagerDescription) {
        coreDataManager = customDataManager
    }

    public func getCardSet(ID: UUID) -> CardSet? {

        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        guard let cardSetMO = coreDataManager.fetch(request: fetchRequest).first else { return nil }


        let cardSet = CardSet(id: cardSetMO.id ?? UUID(), title: cardSetMO.title ?? "", allCardsCount: Int(cardSetMO.allCardsCount), learnedCardsCount: Int(cardSetMO.learnedCardsCount), color: Int(cardSetMO.color))

        return cardSet

    }

    public func addCardSet(set: CardSet) -> Bool {
        coreDataManager.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = set.id
            cardSetMO.title = set.title
            cardSetMO.allCardsCount = Int32(set.allCardsCount)
            cardSetMO.learnedCardsCount = Int32(set.learnedCardsCount)
            cardSetMO.color = Int32(set.color)
        }

        return true
    }

    public func getAllCardSets() -> [CardSet] {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        let cardSets = coreDataManager.fetch(request: fetchRequest)

        return cardSets.map { CardSet(id: $0.id ?? UUID(), title: $0.title ?? "", allCardsCount: Int($0.allCardsCount), learnedCardsCount: Int($0.learnedCardsCount), color: Int($0.color)) }
    }

    public func getAllCardIDsFromSet(setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(CardMO.setID), setID as CVarArg)

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    public func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == false", #keyPath(CardMO.setID), setID as CVarArg, #keyPath(CardMO.isLearned))

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    public func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == true", #keyPath(CardMO.setID), setID as CVarArg, #keyPath(CardMO.isLearned))

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    public func addCard(card: Card, toSet cardSetID: UUID) -> Bool {
        coreDataManager.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = cardSetID
            cardMO.questionText = card.questionText
            cardMO.answerText = card.answerText
            cardMO.isLearned = card.isLearned
            cardMO.questionImageURL = card.questionImageURL
            cardMO.answerImageURL = card.answerImageURL
        }

        return true
    }

    public func deleteCardSet(ID: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)
        
        if coreDataManager.fetch(request: fetchRequest).count == 0 {
            return false
        }

        coreDataManager.delete(request: fetchRequest)

        return true
    }

    public func updateCardSet(oldID: UUID, newSet: CardSet) -> Bool {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", oldID as CVarArg)

        coreDataManager.update(request: fetchRequest) { cardSetMO in
            cardSetMO?.id = newSet.id
            cardSetMO?.title = newSet.title
            cardSetMO?.allCardsCount = Int32(newSet.allCardsCount)
            cardSetMO?.learnedCardsCount = Int32(newSet.learnedCardsCount)
            cardSetMO?.color = Int32(newSet.color)
        }

        return true
    }

    public func deleteAllCardSets() {
        coreDataManager.deleteAll(request: CardSetMO.fetchRequest())
    }
}
