//
//  CoreDataCardRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import Core


public class CoreDataCardRepository: CardRepositoryDescription {

    private let coreDataManager = CoreDataManager.shared
    private let fileManager = MyFileManager.shared
    
    public init() {}

    public func getCard(ID: UUID) -> Card? {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        guard let cardMO = coreDataManager.fetch(request: fetchRequest).first else { return nil }

        let card = Card(id: cardMO.id ?? UUID(), setID: cardMO.setID, questionText: cardMO.questionText, questionImageURL: cardMO.questionImageURL, answerText: cardMO.answerText, answerImageURL: cardMO.answerImageURL, isLearned: cardMO.isLearned)

        return card
    }

    public func addCard(card: Card) -> Bool {
        coreDataManager.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = card.setID
            cardMO.questionText = card.questionText
            cardMO.answerText = card.answerText
            cardMO.isLearned = card.isLearned
            cardMO.questionImageURL = card.questionImageURL
            cardMO.answerImageURL = card.answerImageURL
        }

        return true
    }

    public func updateCard(oldID: UUID, newCard: Card) -> Bool {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", oldID as CVarArg)

        coreDataManager.update(request: fetchRequest) { cardMO in
            cardMO?.id = newCard.id
            cardMO?.setID = newCard.setID
            cardMO?.questionText = newCard.questionText
            cardMO?.answerText = newCard.answerText
            cardMO?.isLearned = newCard.isLearned

            if let questionImgURL = newCard.questionImageURL, questionImgURL != cardMO?.questionImageURL {
                self.fileManager.deleteFile(at: cardMO?.questionImageURL)
                cardMO?.questionImageURL = questionImgURL
            }
            if let answerImgURL = newCard.answerImageURL, answerImgURL != cardMO?.answerImageURL {
                self.fileManager.deleteFile(at: cardMO?.answerImageURL)
                cardMO?.answerImageURL = answerImgURL
            }
        }

        return true
    }

    public func deleteCard(ID: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        if coreDataManager.fetch(request: fetchRequest).count == 0 {
            return false
        }
        
        MyFileManager.shared.deleteFile(at: coreDataManager.fetch(request: fetchRequest).first?.answerImageURL)
        MyFileManager.shared.deleteFile(at: coreDataManager.fetch(request: fetchRequest).first?.questionImageURL)

        coreDataManager.delete(request: fetchRequest)

        return true
    }

    public func deleteAllCards() {
        for card in coreDataManager.fetch(request: CardMO.fetchRequest()) {
            MyFileManager.shared.deleteFile(at: card.questionImageURL)
            MyFileManager.shared.deleteFile(at: card.answerImageURL)
        }
        coreDataManager.deleteAll(request: CardMO.fetchRequest())
    }
}
