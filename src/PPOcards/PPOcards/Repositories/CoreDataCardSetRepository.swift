//
//  CoreDataCardSetRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import UIKit


class CoreDataCardSetRepository: CardSetRepositoryDescription {

    private let coreDataManager = CoreDataManager.shared
    private let fileManager = MyFileManager.shared

    func getCardSet(ID: UUID) -> CardSet? {

        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        guard let cardSetMO = coreDataManager.fetch(request: fetchRequest).first else { return nil }


        let cardSet = CardSet(id: cardSetMO.id ?? UUID(), title: cardSetMO.title ?? "", progress: cardSetMO.progress ?? "", color: cardSetMO.color?.color ?? .black)

        return cardSet

    }

    func addCardSet(set: CardSet) -> Bool {
        coreDataManager.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = set.id
            cardSetMO.title = set.title
            cardSetMO.progress = set.progress
            cardSetMO.color = set.color.data
        }

        return true
    }

    func getAllCardSetIDs() -> [UUID] {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        let cardSetMO = coreDataManager.fetch(request: fetchRequest)

        return cardSetMO.map { $0.id! }
    }

    func getAllCardIDsFromSet(setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(CardMO.setID), setID as CVarArg)

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == false", #keyPath(CardMO.setID), setID as CVarArg, #keyPath(CardMO.isLearned))

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == true", #keyPath(CardMO.setID), setID as CVarArg, #keyPath(CardMO.isLearned))

        let cardMO = coreDataManager.fetch(request: fetchRequest)

        return cardMO.map { $0.id! }
    }

    func addCard(card: Card, toSet cardSetID: UUID) -> Bool {
        coreDataManager.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = cardSetID
            cardMO.questionText = card.questionText
            cardMO.answerText = card.answerText
            cardMO.isLearned = card.isLearned

            var questionImgPath: URL? = nil
            var answerImgPath: URL? = nil

            if let questionImg = card.questionImage {
                questionImgPath = self.fileManager.putImageToFS(with: questionImg)
            }
            if let answerImg = card.answerImage {
                answerImgPath = self.fileManager.putImageToFS(with: answerImg)
            }

            cardMO.questionImageURL = questionImgPath
            cardMO.answerImageURL = answerImgPath

        }

        return true
    }

    func deleteCardSet(ID: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        coreDataManager.delete(request: fetchRequest)

        return true
    }

    func updateCardSet(oldID: UUID, newSet: CardSet) -> Bool {
        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", oldID as CVarArg)

        coreDataManager.update(request: fetchRequest) { cardSetMO in
            cardSetMO?.id = newSet.id
            cardSetMO?.title = newSet.title
            cardSetMO?.progress = newSet.progress
            cardSetMO?.color = newSet.color.data
        }

        return true
    }


}
