//
//  PPOCardRepositoryIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
import CoreData
@testable import PPOcards

final class PPOCardRepositoryIntegrationTests: XCTestCase {

    private let db = CoreDataManager.shared
    private let fileManager = MyFileManager.shared

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    func test_getCard() {
        let cardRepository = CoreDataCardRepository()

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)

        db.create(entityName: "CardMO") { cardMO in
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

        let res = cardRepository.getCard(ID: id)

        XCTAssertEqual(card, res)
    }

    func test_addCard() {
        let cardRepository = CoreDataCardRepository()

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)

        let rc = cardRepository.addCard(card: card)
        XCTAssertEqual(rc, true)

        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let cardMO = db.fetch(request: fetchRequest).first else { return }

        let cardRes = Card(id: cardMO.id ?? UUID(), setID: cardMO.setID, questionText: cardMO.questionText, questionImage: nil, answerText: cardMO.answerText, answerImage: nil, isLearned: cardMO.isLearned)

        XCTAssertEqual(card, cardRes)
    }

    func test_updateCard() {
        let cardRepository = CoreDataCardRepository()

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)
        let id1 = UUID()
        let card1 = Card(id: id1, setID: nil, isLearned: false)

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = card.setID
            cardMO.questionText = card.questionText
            cardMO.answerText = card.answerText
            cardMO.isLearned = card.isLearned
            cardMO.questionImageURL = nil
            cardMO.answerImageURL = nil

        }

        let rc = cardRepository.updateCard(oldID: id, newCard: card1)
        XCTAssertEqual(rc, true)

        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id1 as CVarArg)

        guard let cardMO = db.fetch(request: fetchRequest).first else { return }


        let cardRes = Card(id: cardMO.id ?? UUID(), setID: cardMO.setID, questionText: cardMO.questionText, questionImage: nil, answerText: cardMO.answerText, answerImage: nil, isLearned: cardMO.isLearned)

        XCTAssertEqual(card1, cardRes)
    }

    func test_deleteCard() {
        let cardRepository = CoreDataCardRepository()

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)

        db.delete(request: CardMO.fetchRequest())

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card.id
            cardMO.setID = card.setID
            cardMO.questionText = card.questionText
            cardMO.answerText = card.answerText
            cardMO.isLearned = card.isLearned
            cardMO.questionImageURL = nil
            cardMO.answerImageURL = nil

        }

        var res = db.fetch(request: CardMO.fetchRequest())

        XCTAssertEqual(res.count, 1)

        let rc = cardRepository.deleteCard(ID: id)
        XCTAssertEqual(rc, true)

        res = db.fetch(request: CardMO.fetchRequest())

        XCTAssertEqual(res.count, 0)
    }

}
