//
//  PPOcardsIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
import CoreData
@testable import PPOcards

final class PPOCardSetRepositoryIntegrationTests: XCTestCase {

    private let db = CoreDataManager.shared
    private let fileManager = MyFileManager.shared

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    func test_GetCardSet_empty() {
        let cardSetRepository = CoreDataCardSetRepository()

        let res = cardSetRepository.getCardSet(ID: UUID())

        XCTAssertEqual(res, nil)
    }

    func test_GetCardSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id = UUID()
        let set = CardSet(id: id, title: "test_GetCardSet", progress: "0/0", color: 0x0000FF)
        db.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = set.id
            cardSetMO.title = set.title
            cardSetMO.progress = set.progress
            cardSetMO.color = Int32(set.color)
        }

        let res = cardSetRepository.getCardSet(ID: id)

        XCTAssertEqual(set, res)
    }

    func test_addCardSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id = UUID()
        let set = CardSet(id: id, title: "test_addCardSet", progress: "0/0", color: 0x0000FF)
        let rc = cardSetRepository.addCardSet(set: set)
        XCTAssertEqual(rc, true)

        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        guard let cardSetMO = db.fetch(request: fetchRequest).first else { return }

        let cardSet = CardSet(id: cardSetMO.id ?? UUID(), title: cardSetMO.title ?? "", progress: cardSetMO.progress ?? "", color: Int(cardSetMO.color))

        XCTAssertEqual(set, cardSet)
    }

    func test_getAllCardSetIDs() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id1 = UUID()
        let id2 = UUID()
        let set1 = CardSet(id: id1, title: "test_GetCardSet", progress: "0/0", color: 0x0000FF)
        let set2 = CardSet(id: id2, title: "test_GetCardSet", progress: "0/0", color: 0x0000FF)

        db.delete(request: CardSetMO.fetchRequest())

        db.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = set1.id
            cardSetMO.title = set1.title
            cardSetMO.progress = set1.progress
            cardSetMO.color = Int32(set1.color)
        }
        db.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = set2.id
            cardSetMO.title = set2.title
            cardSetMO.progress = set2.progress
            cardSetMO.color = Int32(set2.color)
        }

        let res = cardSetRepository.getAllCardSetIDs()

        XCTAssertEqual(Set([id1, id2]), Set(res))
    }

    func test_getAllCardIDsFromSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        db.delete(request: CardMO.fetchRequest())

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card1.id
            cardMO.setID = id3
            cardMO.questionText = card1.questionText
            cardMO.answerText = card1.answerText
            cardMO.isLearned = card1.isLearned
            cardMO.questionImageURL = card1.questionImageURL
            cardMO.answerImageURL = card1.answerImageURL
        }

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card2.id
            cardMO.setID = id3
            cardMO.questionText = card2.questionText
            cardMO.answerText = card2.answerText
            cardMO.isLearned = card2.isLearned
            cardMO.questionImageURL = card2.questionImageURL
            cardMO.answerImageURL = card2.answerImageURL
        }

        let res = cardSetRepository.getAllCardIDsFromSet(setID: id3)

        XCTAssertEqual(Set([id1, id2]), Set(res))
    }

    func test_getNotLearnedCardIDsFromSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        db.delete(request: CardMO.fetchRequest())

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card1.id
            cardMO.setID = id3
            cardMO.questionText = card1.questionText
            cardMO.answerText = card1.answerText
            cardMO.isLearned = card1.isLearned
            cardMO.questionImageURL = card1.questionImageURL
            cardMO.answerImageURL = card1.answerImageURL
        }

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card2.id
            cardMO.setID = id3
            cardMO.questionText = card2.questionText
            cardMO.answerText = card2.answerText
            cardMO.isLearned = card2.isLearned
            cardMO.questionImageURL = card2.questionImageURL
            cardMO.answerImageURL = card2.answerImageURL
        }

        let res = cardSetRepository.getNotLearnedCardIDsFromSet(from: id3)

        XCTAssertEqual(Set([id2]), Set(res))
    }

    func test_getLearnedCardIDsFromSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        db.delete(request: CardMO.fetchRequest())

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card1.id
            cardMO.setID = id3
            cardMO.questionText = card1.questionText
            cardMO.answerText = card1.answerText
            cardMO.isLearned = card1.isLearned
            cardMO.questionImageURL = card1.questionImageURL
            cardMO.answerImageURL = card1.answerImageURL
        }

        db.create(entityName: "CardMO") { cardMO in
            guard let cardMO = cardMO as? CardMO else { return }

            cardMO.id = card2.id
            cardMO.setID = id3
            cardMO.questionText = card2.questionText
            cardMO.answerText = card2.answerText
            cardMO.isLearned = card2.isLearned
            cardMO.questionImageURL = card2.questionImageURL
            cardMO.answerImageURL = card2.answerImageURL
        }

        let res = cardSetRepository.getLearnedCardIDsFromSet(from: id3)

        XCTAssertEqual(Set([id1]), Set(res))
    }

    func test_addCard() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id1 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)

        db.delete(request: CardMO.fetchRequest())

        let rc = cardSetRepository.addCard(card: card1, toSet: id3)
        XCTAssertEqual(rc, true)

        let fetchRequest: NSFetchRequest<CardMO> = CardMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id1 as CVarArg)

        guard let cardMO = db.fetch(request: fetchRequest).first else { return }

        let cardRes = Card(id: cardMO.id ?? UUID(), setID: cardMO.setID, questionText: cardMO.questionText, questionImageURL: cardMO.questionImageURL, answerText: cardMO.answerText, answerImageURL: cardMO.answerImageURL, isLearned: cardMO.isLearned)

        XCTAssertEqual(card1, cardRes)
    }

    func test_deleteCardSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let id = UUID()
        let cs = CardSet(id: id, title: "deleteCardSet", progress: "0/0", color: 0x0000FF)

        db.delete(request: CardSetMO.fetchRequest())

        db.create(entityName: "CardSetMO") { cardSetMO in
            guard let cardSetMO = cardSetMO as? CardSetMO else { return }

            cardSetMO.id = cs.id
            cardSetMO.title = cs.title
            cardSetMO.progress = cs.progress
            cardSetMO.color = Int32(cs.color)
        }

        var res = db.fetch(request: CardSetMO.fetchRequest())

        XCTAssertEqual(res.count, 1)

        let rc = cardSetRepository.deleteCardSet(ID: id)
        XCTAssertEqual(rc, true)

        res = db.fetch(request: CardSetMO.fetchRequest())

        XCTAssertEqual(res.count, 0)
    }

    func test_updateCardSet() {
        let cardSetRepository = CoreDataCardSetRepository()

        let idOld = UUID()
        let idNew = UUID()

        let csOld = CardSet(id: idOld, title: "deleteCardSet", progress: "0/0", color: 0x0000FF)
        let csNew = CardSet(id: idNew, title: "deleteCardSet", progress: "0/0", color: 0x0000FF)

        db.delete(request: CardSetMO.fetchRequest())

        let rc = cardSetRepository.addCardSet(set: csOld)
        XCTAssertEqual(rc, true)

        let rc2 = cardSetRepository.updateCardSet(oldID: csOld.id, newSet: csNew)
        XCTAssertEqual(rc2, true)

        let fetchRequest: NSFetchRequest<CardSetMO> = CardSetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", csNew.id as CVarArg)

        guard let cardSetMO = db.fetch(request: fetchRequest).first else { return }


        let cardSetRes = CardSet(id: cardSetMO.id ?? UUID(), title: cardSetMO.title ?? "", progress: cardSetMO.progress ?? "", color: Int(cardSetMO.color))

        XCTAssertEqual(csNew, cardSetRes)
    }

}

