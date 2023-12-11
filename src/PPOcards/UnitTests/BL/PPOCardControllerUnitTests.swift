//
//  PPOcardsTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 28.03.2023.
//

import XCTest
import Services
import CoreData
import DBCoreData
@testable import Core

final class PPOCardControllerUnitTests: XCTestCase {

    var cardController: CardController!
    var mockDB: MockCoreDataManager!
    let context = NSPersistentContainer(name: "DataBasePPOCardsUnitTests").viewContext

    override func setUp() {
        super.setUp()
        ModelProvider.shared.setupDB(type: .CoreData)
        mockDB = MockCoreDataManager()
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = SettingsMO(context: self.context)
            res.isMixed = false
            res.mixingInPower = 0
            return [res]
        }
        let cardSetController = CardSetController(
            dataSource: CoreDataCardSetRepository(customDataManager: mockDB),
            settingsController: SettingsController(dataSource: CoreDataSettingsRepository(customDataManager: mockDB))
        )
        cardController = CardController(
            dataSource: CoreDataCardRepository(customDataManager: mockDB),
            cardSetController: cardSetController
        )

    }

    override func tearDown() {
        cardController = nil
        super.tearDown()
    }

    func test_Unit_BL_GetCard() {
        feature("Тест получения карточки по ID")

        // Arrange
        let testCard = CardFabric.getCard(withSimpleID: 1)
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardMO(context: self.context)
            res.id = testCard.id
            res.setID = testCard.setID
            res.isLearned = testCard.isLearned
            return [res]
        }

        // Act
        let result = cardController.getCard(ID: testCard.id)

        // Assert
        step("Проверка совпадения тестовой карточки и карточки из БД") {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, testCard)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_CreateCard() {
        feature("Тест создания карточки")

        // Arrange
        let testCard = CardFabric.getCard(withSimpleID: 0)
        mockDB.registerResult(for: \.createRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = UUID()
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }

        // Act
        let result = cardController.createCard(for: testCard.setID!)

        // Assert
        step("Проверка совпадения setID тестовой карточки с этолонным") {
            XCTAssertEqual(result.setID, testCard.setID)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.createRef, numberOfTimes: 2))
        }
    }

    func test_Unit_BL_UpdateCard() {
        feature("Тест обновления карточки")

        // Arrange
        let cardAfterUpdate = CardFabric.getUpdatedCard(withSimpleID: 1)
        mockDB.registerResult(for: mockDB.updateRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = UUID()
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }

        // Act
        let updateRC = cardController.updateCard(oldID: UUID(), new: cardAfterUpdate)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(updateRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_BL_DeleteCard() {
        feature("Тест удаления карточки")

        // Arrange
        mockDB.registerResult(for: \.deleteRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = UUID()
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }

        // Act
        let removeRC = cardController.deleteCard(ID: UUID())

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(removeRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteRef))
        }
    }

    func test_Unit_BL_GetCardProgress() {
        feature("Тест получения прогресса изучения карточки")

        // Arrange
        let cardId = UUID()
        let cardSetId = UUID()
        let expectedRes = CardProgress(cardSetId: cardSetId, cardId: cardId, successCount: 1, allAttemptsCount: 5)
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            let res = CardProgressMO(context: self.context)
            res.cardId = cardId
            res.cardSetId = cardSetId
            res.successCount = 1
            res.allAttemptsCount = 5
            return [res]
        }

        // Act
        let result = cardController.getCardProgress(cardSetID: cardSetId, cardID: cardId)

        // Assert
        step("Проверка совпадения тестового прогресса и полученного") {
            XCTAssertEqual(result, expectedRes)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_ShareCardToSet() {
        feature("Тест шаринга карточки в другой набор")

        // Arrange
        let setIdToShare = CardFabric.setUUID(param: 2)
        let testCard = CardFabric.getCard(withSimpleID: 1)
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = testCard.id
                res.setID = testCard.setID
                res.isLearned = testCard.isLearned
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }

        // Act
        let shareResult = cardController.shareCardToSet(cardID: testCard.id, newSetID: setIdToShare)

        // Assert
        step("Проверка совпадения setID перемещенной карточки с целевым") {
            XCTAssertEqual(shareResult?.setID, setIdToShare)
        }
    }

    func test_Unit_BL_DeleteAllCards() {
        feature("Тест удаления всех карточек")

        // Arrange
        mockDB.registerResult(for: \.deleteAllRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            let res = CardMO(context: self.context)
            return [res]
        }

        // Act
        cardController.deleteAllCards()

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteAllRef))
        }
    }

    func test_Unit_BL_MarkAsLearned() {
        feature("Тест пометки карточки как выученной")

        // Arrange
        let testCard = CardFabric.getCard(withSimpleID: 1)
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = UUID()
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }
        mockDB.registerResult(for: mockDB.updateRef) { args in }

        // Act
        cardController.markAsLearned(cardID: testCard.id)

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_BL_MarkAsNotLearned() {
        feature("Тест пометки карточки как невыученной")

        // Arrange
        let testCard = CardFabric.getCard(withSimpleID: 1)
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            if args.entityName == "CardMO" {
                let res = CardMO(context: self.context)
                res.id = UUID()
                return [res]
            } else if args.entityName == "CardSetMO" {
                let res = CardSetMO(context: self.context)
                res.id = UUID()
                return [res]
            } else {
                return []
            }
        }
        mockDB.registerResult(for: mockDB.updateRef) { args in }

        // Act
        cardController.markAsLearned(cardID: testCard.id)

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

}
