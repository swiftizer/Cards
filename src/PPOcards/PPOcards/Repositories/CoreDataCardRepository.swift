//
//  CoreDataCardRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import UIKit


class CoreDataCardRepository: CardRepositoryDescription {

    private let coreDataManager = CoreDataManager.shared
    private let fileManager = MyFileManager.shared

    func getCard(ID: UUID) -> Card? {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        guard let cardMO = coreDataManager.fetch(request: fetchRequest).first else { return nil }

        var questionImg: UIImage? = nil
        var answerImg: UIImage? = nil

        if let questionImgURL = cardMO.questionImageURL {
            questionImg = self.fileManager.getImageFromFS(path: questionImgURL)
        }
        if let answerImgURL = cardMO.answerImageURL {
            answerImg = self.fileManager.getImageFromFS(path: answerImgURL)
        }


        let card = Card(id: cardMO.id ?? UUID(), setID: cardMO.setID, questionText: cardMO.questionText, questionImage: questionImg, answerText: cardMO.answerText, answerImage: answerImg, isLearned: cardMO.isLearned)

        return card
    }

    func addCard(card: Card) -> Bool {
        coreDataManager.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = card.setID
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

    func updateCard(oldID: UUID, newCard: Card) -> Bool {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", oldID as CVarArg)

        coreDataManager.update(request: fetchRequest) { cardMO in
            cardMO?.id = newCard.id
            cardMO?.setID = newCard.setID
            cardMO?.questionText = newCard.questionText
            cardMO?.answerText = newCard.answerText
            cardMO?.isLearned = newCard.isLearned

            if let questionImg = newCard.questionImage {
                self.fileManager.deleteFile(at: cardMO?.questionImageURL)
                let questionImgPath = self.fileManager.putImageToFS(with: questionImg)
                cardMO?.questionImageURL = questionImgPath
            }
            if let answerImg = newCard.answerImage {
                self.fileManager.deleteFile(at: cardMO?.answerImageURL)
                let answerImgPath = self.fileManager.putImageToFS(with: answerImg)
                cardMO?.answerImageURL = answerImgPath
            }
        }

        return true
    }

    func deleteCard(ID: UUID) -> Bool {
        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)

        coreDataManager.delete(request: fetchRequest)

        return true
    }


}
