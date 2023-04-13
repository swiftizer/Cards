//
//  PPOcardSetControllerTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 30.03.2023.
//

import XCTest
@testable import PPOcards

final class PPOCardSetControllerUnitTests: XCTestCase {

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    func test_GetCardSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let res = cardSetController.createCardSet(title: "test_GetCardSet")

        XCTAssertEqual(cardSetController.getCardSet(ID: res.id), CardSet(id: res.id, title: "test_GetCardSet", progress: "0/0", color: 0xFF0000))
    }

    func test_CreateCardSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let testCardSet = cardSetController.createCardSet(title: "aboba")
        let testRefCardSet = CardSet(id: UUID(), title: "aboba", progress: "0/0", color: 0xFF0000)

        XCTAssertEqual(testCardSet.title, testRefCardSet.title)
        XCTAssertEqual(testCardSet.progress, testRefCardSet.progress)
        XCTAssertEqual(testCardSet.color, testRefCardSet.color)
    }

    func test_AddCard() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        XCTAssertEqual(cardSetController.addCard(card: Card(id: UUID(), setID: UUID(), isLearned: true), toSet: UUID()), true)
    }

    func test_DeleteCardSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        XCTAssertEqual(cardSetController.deleteCardSet(ID: UUID()), true)
    }

    func test_GetLearnedCardIDsFromSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(cardSetController.getLearnedCardIDsFromSet(from: cs.id), [id1])
    }

    func test_GetNotLearnedCardIDsFromSet_mixing_0() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getNotLearnedCardIDsFromSet(from: cs.id)).intersection(Set(cardSetController.getLearnedCardIDsFromSet(from: cs.id))).count, 0)
    }

    func test_GetNotLearnedCardIDsFromSet_mixing_50() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let rc = settingsController.updateSettings(to: Settings(isMixed: false, mixingInPower: 50))

        XCTAssertEqual(rc, true)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getNotLearnedCardIDsFromSet(from: cs.id)).intersection(Set(cardSetController.getLearnedCardIDsFromSet(from: cs.id))).count, 1)
    }

    func test_GetNotLearnedCardIDsFromSet_mixing_80() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let rc = settingsController.updateSettings(to: Settings(isMixed: false, mixingInPower: 80))

        XCTAssertEqual(rc, true)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getNotLearnedCardIDsFromSet(from: cs.id)).intersection(Set(cardSetController.getLearnedCardIDsFromSet(from: cs.id))).count, 2)
    }

    func test_GetNotLearnedCardIDsFromSet_mixing_250() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let rc = settingsController.updateSettings(to: Settings(isMixed: false, mixingInPower: 250))

        XCTAssertEqual(rc, true)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getNotLearnedCardIDsFromSet(from: cs.id)).intersection(Set(cardSetController.getLearnedCardIDsFromSet(from: cs.id))).count, 2)
    }

    func test_GetNotLearnedCardIDsFromSet_mixing_minus() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let rc = settingsController.updateSettings(to: Settings(isMixed: false, mixingInPower: -10))

        XCTAssertEqual(rc, true)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getNotLearnedCardIDsFromSet(from: cs.id)).intersection(Set(cardSetController.getLearnedCardIDsFromSet(from: cs.id))).count, 0)
    }

    func test_GetAllCardIDsFromSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        let cs = cardSetController.createCardSet(title: "test_GetCardSet")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let id4 = UUID()

        let _ = cardSetController.addCard(card: Card(id: id1, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id2, setID: nil, isLearned: true), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id3, setID: nil, isLearned: false), toSet: cs.id)
        let _ = cardSetController.addCard(card: Card(id: id4, setID: nil, isLearned: false), toSet: cs.id)

        XCTAssertEqual(Set(cardSetController.getAllCardIDsFromSet(from: cs.id)), Set([id1, id2, id3, id4]))
    }

    func test_UpdateCardSet() {
        let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
        let cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)

        XCTAssertEqual(cardSetController.updateCardSet(oldID: UUID(), new: CardSet(id: UUID(), title: "aboba2", progress: "5/10", color: 0xFF0000)), true)
    }

}
