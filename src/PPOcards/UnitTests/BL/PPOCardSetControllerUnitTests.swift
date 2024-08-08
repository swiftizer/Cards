//
//  PPOcardSetControllerTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 30.03.2023.
//

import XCTest
import Services
import CoreData
import DBCoreData
@testable import Core

final class PPOCardSetControllerUnitTests: XCTestCase {

    var cardSetController: CardSetController!
    var settingsController: SettingsController!
    var mockDB: MockCoreDataManager!
    let context = NSPersistentContainer(name: "DataBasePPOCardsUnitTests").viewContext

    override func setUp() {
        ModelProvider.shared.setupDB(type: .CoreData)
        mockDB = MockCoreDataManager()
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = SettingsMO(context: self.context)
            res.isMixed = false
            res.mixingInPower = 0
            return [res]
        }
        settingsController = SettingsController(dataSource: CoreDataSettingsRepository(customDataManager: mockDB))
        cardSetController = CardSetController(
            dataSource: CoreDataCardSetRepository(customDataManager: mockDB),
            settingsController: settingsController
        )
    }

    override func tearDown() {
        cardSetController = nil
        settingsController = nil
        super.tearDown()
    }

    func setUp(settings: Settings) {
        mockDB = MockCoreDataManager()
        mockDB.registerResult(for: \.fetchRef) { args in
            var res = SettingsMO(context: self.context)
            res = settings.toCoreData(settingsMO: res)
            return [res]
        }
        settingsController = SettingsController(dataSource: CoreDataSettingsRepository(customDataManager: mockDB))
        cardSetController = CardSetController(
            dataSource: CoreDataCardSetRepository(customDataManager: mockDB),
            settingsController: settingsController
        )
    }

    func test_Unit_BL_GetAllCardSets() {
        feature("Тест получения всех наборов карточек")

        // Arrange
        let testCS = CardSetFabric.getCardSet(withSimpleID: 1)
        let testCS2 = CardSetFabric.getCardSet(withSimpleID: 2)
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardSetMO(context: self.context)
            res.id = testCS.id
            res.title = testCS.title
            res.allCardsCount = Int32(testCS.allCardsCount)
            res.learnedCardsCount = Int32(testCS.learnedCardsCount)
            res.color = Int32(testCS.color)
            let res2 = CardSetMO(context: self.context)
            res2.id = testCS2.id
            res2.title = testCS2.title
            res2.allCardsCount = Int32(testCS2.allCardsCount)
            res2.learnedCardsCount = Int32(testCS2.learnedCardsCount)
            res2.color = Int32(testCS2.color)
            return [res, res2]
        }

        // Act
        let result = cardSetController.getAllCardSets()

        // Assert
        step("Проверка находжения всех созданных наборов в результате") {
            XCTAssertTrue(result.contains(testCS))
            XCTAssertTrue(result.contains(testCS2))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetCardSet() {
        feature("Тест получения набора карточек по ID")

        // Arrange
        let testCS = CardSetFabric.getCardSet(withSimpleID: 1)
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardSetMO(context: self.context)
            res.id = testCS.id
            res.title = testCS.title
            res.allCardsCount = Int32(testCS.allCardsCount)
            res.learnedCardsCount = Int32(testCS.learnedCardsCount)
            res.color = Int32(testCS.color)
            return [res]
        }

        // Act
        let result = cardSetController.getCardSet(ID: testCS.id)

        // Assert
        step("Проверка совпадения тестового набора и эталонного") {
            XCTAssertNotNil(result)
            XCTAssertEqual(testCS, result)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_CreateCardSet() {
        feature("Тест создания набора карточек")

        // Arrange
        let testCardSet = CardSetFabric.getCardSet(withSimpleID: 0)
        mockDB.registerResult(for: \.createRef) { args in }

        // Act
        let result = cardSetController.createCardSet(title: testCardSet.title)

        // Assert
        step("Проверка возврата созданного набора") {
            XCTAssertEqual(result.title, testCardSet.title)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.createRef, numberOfTimes: 1))
        }
    }

    func test_Unit_BL_AddCard() {
        feature("Тест добавления карточки в набор")

        // Arrange
        let testCard = CardSetFabric.getCard(withSimpleID: 0)
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
        let addRC = cardSetController.addCard(card: testCard, toSet: CardSetFabric.setUUID(param: 1))

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(addRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.createRef))
        }
    }

    func test_Unit_BL_GetLearnedCardIDsFromSet() {
        feature("Тест получения выученных карточек из набора")

        // Arrange
        let testCard = CardSetFabric.getLearnedCard(withSimpleID: 1)
        let testCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 2)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            if predicate.contains("isLearned == 1") {
                let res = CardMO(context: self.context)
                res.id = testCard.id
                res.setID = testCard.setID
                res.isLearned = testCard.isLearned
                result.append(res)
            } else {
                let res = CardMO(context: self.context)
                res.id = testCard2.id
                res.setID = testCard2.setID
                res.isLearned = testCard2.isLearned
                result.append(res)
            }
            return result
        }

        // Act
        let result = cardSetController.getLearnedCardIDsFromSet(from: testCard.id)

        // Assert
        step("Проверка совпадения тестовой выученной карточки и полученной") {
            XCTAssertEqual(result, [testCard.id])
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetNotLearnedCardIDsFromSet_mixing_0() {
        feature("Тест получения невыученных карточек из набора (подмешивание 0%)")

        // Arrange
        setUp(settings: Settings(isMixed: false, mixingInPower: 0))
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            if predicate.contains("isLearned == 1") {
                result = [learnedCard1.toCoreData(createdCardMO: res1), learnedCard2.toCoreData(createdCardMO: res2)]
            } else {
                result = [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2)]
            }
            return result
        }

        // Act
        let result = cardSetController.getNotLearnedCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов с ожидаемым") {
            XCTAssertTrue(result.contains(notLearnedCard1.id))
            XCTAssertTrue(result.contains(notLearnedCard2.id))
            XCTAssertTrue(result.count == 2)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetNotLearnedCardIDsFromSet_mixing_50() {
        feature("Тест получения невыученных карточек из набора (подмешивание 50%)")

        // Arrange
        setUp(settings: Settings(isMixed: false, mixingInPower: 50))
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            if predicate.contains("isLearned == 1") {
                result = [learnedCard1.toCoreData(createdCardMO: res1), learnedCard2.toCoreData(createdCardMO: res2)]
            } else {
                result = [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2)]
            }
            return result
        }

        // Act
        let result = cardSetController.getNotLearnedCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов с ожидаемым") {
            XCTAssertTrue(result.contains(notLearnedCard1.id))
            XCTAssertTrue(result.contains(notLearnedCard2.id))
            XCTAssertTrue(result.contains(learnedCard1.id) || result.contains(learnedCard2.id))
            XCTAssertTrue(result.count == 3)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetNotLearnedCardIDsFromSet_mixing_80() {
        feature("Тест получения невыученных карточек из набора (подмешивание 80%)")

        // Arrange
        setUp(settings: Settings(isMixed: false, mixingInPower: 80))
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            if predicate.contains("isLearned == 1") {
                result = [learnedCard1.toCoreData(createdCardMO: res1), learnedCard2.toCoreData(createdCardMO: res2)]
            } else {
                result = [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2)]
            }
            return result
        }

        // Act
        let result = cardSetController.getNotLearnedCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов с ожидаемым") {
            XCTAssertTrue(result.contains(notLearnedCard1.id))
            XCTAssertTrue(result.contains(notLearnedCard2.id))
            XCTAssertTrue(result.contains(learnedCard1.id))
            XCTAssertTrue(result.contains(learnedCard2.id))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetNotLearnedCardIDsFromSet_mixing_250() {
        feature("Тест получения невыученных карточек из набора (подмешивание 250%)")

        // Arrange
        setUp(settings: Settings(isMixed: false, mixingInPower: 250))
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            if predicate.contains("isLearned == 1") {
                result = [learnedCard1.toCoreData(createdCardMO: res1), learnedCard2.toCoreData(createdCardMO: res2)]
            } else {
                result = [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2)]
            }
            return result
        }

        // Act
        let result = cardSetController.getNotLearnedCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов с ожидаемым") {
            XCTAssertTrue(result.contains(notLearnedCard1.id))
            XCTAssertTrue(result.contains(notLearnedCard2.id))
            XCTAssertTrue(result.contains(learnedCard1.id))
            XCTAssertTrue(result.contains(learnedCard2.id))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetNotLearnedCardIDsFromSet_mixing_minus() {
        feature("Тест получения невыученных карточек из набора (подмешивание -10%)")

        // Arrange
        setUp(settings: Settings(isMixed: false, mixingInPower: -10))
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            guard let predicate = args.predicate?.predicateFormat else { return [] }
            var result = [CardMO]()
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            if predicate.contains("isLearned == 1") {
                result = [learnedCard1.toCoreData(createdCardMO: res1), learnedCard2.toCoreData(createdCardMO: res2)]
            } else {
                result = [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2)]
            }
            return result
        }

        // Act
        let result = cardSetController.getNotLearnedCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов с ожидаемым") {
            XCTAssertTrue(result.contains(notLearnedCard1.id))
            XCTAssertTrue(result.contains(notLearnedCard2.id))
            XCTAssertTrue(result.count == 2)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_GetAllCardIDsFromSet() {
        feature("Тест получения всех карточек из набора")

        // Arrange
        let notLearnedCard1 = CardSetFabric.getNotLearnedCard(withSimpleID: 0)
        let notLearnedCard2 = CardSetFabric.getNotLearnedCard(withSimpleID: 1)
        let learnedCard1 = CardSetFabric.getLearnedCard(withSimpleID: 2)
        let learnedCard2 = CardSetFabric.getLearnedCard(withSimpleID: 3)
        mockDB.registerResult(for: \.fetchRef) { args in
            var res1 = CardMO(context: self.context)
            var res2 = CardMO(context: self.context)
            var res3 = CardMO(context: self.context)
            var res4 = CardMO(context: self.context)
            return [notLearnedCard1.toCoreData(createdCardMO: res1), notLearnedCard2.toCoreData(createdCardMO: res2), learnedCard1.toCoreData(createdCardMO: res3), learnedCard2.toCoreData(createdCardMO: res4)]
        }

        // Act
        let result = cardSetController.getAllCardIDsFromSet(from: UUID())

        // Assert
        step("Проверка совпадения полученных наборов карточек с ожидаемыми") {
            XCTAssertEqual(Set(result), Set([notLearnedCard1.id, notLearnedCard2.id, learnedCard1.id, learnedCard2.id]))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_UpdateCardSet() {
        feature("Тест обновления набора карточек")

        // Arrange
        let cardSetAfterUpdate = CardSetFabric.getUpdatedCardSet(withSimpleID: 1)
        mockDB.registerResult(for: mockDB.updateRef) { args in }

        // Act
        let updateRC = cardSetController.updateCardSet(oldID: UUID(), new: cardSetAfterUpdate)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(updateRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_BL_DeleteCardSet() {
        feature("Тест удаления набора карточек")

        // Arrange
        mockDB.registerResult(for: \.deleteRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            let res = CardMO(context: self.context)
            res.id = UUID()
            return [res]
        }

        // Act
        let removeRC = cardSetController.deleteCardSet(ID: UUID())

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(removeRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteRef))
        }
    }

    func test_Unit_BL_DeleteAllCardSets() {
        feature("Тест удаления всех наборов карточек")

        // Arrange
        mockDB.registerResult(for: \.deleteAllRef) { args in }

        // Act
        cardSetController.deleteAllCardSets()

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteAllRef))
        }
    }

    func test_Unit_BL_UpdateCardSetProgress() {
        feature("Тест обновления прогресса набора карточек")

        // Arrange
        mockDB.registerResult(for: \.updateRef) { args in }
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
        cardSetController.updateCardSetProgress(cardSetID: UUID())

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

}
