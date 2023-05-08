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
        
        coreDataManager.create(entityName: "CardProgressMO") { cardProgressMO in
            guard let cardProgressMO = cardProgressMO as? CardProgressMO else { return }

            cardProgressMO.cardSetId = card.setID
            cardProgressMO.cardId = card.id
            cardProgressMO.successCount = 0
            cardProgressMO.allAttemptsCount = 0
        }

        return true
    }

    public func updateCard(oldID: UUID, newCard: Card, isRestart: Bool = false) -> Bool {
        var successLearnedIncrement = 0
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", oldID as CVarArg)

        coreDataManager.update(request: fetchRequest) { cardMO in
            cardMO?.id = newCard.id
            cardMO?.setID = newCard.setID
            cardMO?.questionText = newCard.questionText
            cardMO?.answerText = newCard.answerText
            successLearnedIncrement = newCard.isLearned.intRepresentation() - (cardMO?.isLearned.intRepresentation() ?? 0)
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
        
        if !isRestart {
            let fetchRequestProgress: NSFetchRequest<CardProgressMO> = CardProgressMO.fetchRequest()
            fetchRequestProgress.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(CardProgressMO.cardSetId), (newCard.setID ?? UUID()) as CVarArg, #keyPath(CardProgressMO.cardId), newCard.id as CVarArg)
            
            coreDataManager.update(request: fetchRequestProgress) { cardProgressMO in
                cardProgressMO?.allAttemptsCount += 1
                cardProgressMO?.successCount += Int32(successLearnedIncrement)
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
        coreDataManager.deleteAll(request: CardProgressMO.fetchRequest())
    }
    
    public func getCardProgress(cardSetID: UUID, cardID: UUID) -> CardProgress? {
        let fetchRequest: NSFetchRequest<CardProgressMO> = CardProgressMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(CardProgressMO.cardSetId), cardSetID as CVarArg, #keyPath(CardProgressMO.cardId), cardID as CVarArg)

        guard let cardProgressMO = coreDataManager.fetch(request: fetchRequest).first else { return nil }

        let cardProgress = CardProgress(cardSetId: cardProgressMO.cardSetId ?? UUID(), cardId: cardProgressMO.cardId ?? UUID(), successCount: Int(cardProgressMO.successCount), allAttemptsCount: Int(cardProgressMO.allAttemptsCount))

        return cardProgress
    }
    
    public func shareCardToSet(cardID: UUID, newSetID: UUID) -> Bool {
        guard var card = getCard(ID: cardID) else { return false }
        
        return addCard(card: Card(id: UUID(), setID: newSetID, questionText: card.questionText, questionImageURL: card.questionImageURL, answerText: card.answerText, answerImageURL: card.answerImageURL, isLearned: false))
    }
}
