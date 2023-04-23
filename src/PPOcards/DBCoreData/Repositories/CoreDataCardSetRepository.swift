//
//  CoreDataCardSetRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import Core


public class CoreDataCardSetRepository: CardSetRepositoryDescription {

    private let coreDataManager = CoreDataManager.shared
    private let fileManager = MyFileManager.shared
    
    public init() {}

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

    public func getAllCardSetIDs() -> [UUID] {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        let cardSetMO = coreDataManager.fetch(request: fetchRequest)

        return cardSetMO.map { $0.id! }
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


}
