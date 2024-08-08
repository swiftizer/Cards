//
//  PPOCardRepositoryUnitTests.swift
//  UnitTests
//
//  Created by ser.nikolaev on 22.10.2023.
//

import XCTest
import Services
import CoreData
import Core
@testable import DBCoreData

class CardBuilder {
    private var id = UUID()
    private var setID = UUID()
    private var questionText: String?
    private var questionImageURL: URL?
    private var answerText: String?
    private var answerImageURL: URL?
    private var isLearned = false

    func withId(_ id: UUID) -> CardBuilder {
        self.id = id
        return self
    }

    func withSetID(_ setID: UUID) -> CardBuilder {
        self.setID = setID
        return self
    }

    func withQuestionText(_ questionText: String) -> CardBuilder {
        self.questionText = questionText
        return self
    }

    func withQuestionImageURL(_ questionImageURL: URL) -> CardBuilder {
        self.questionImageURL = questionImageURL
        return self
    }

    func withAnswerText(_ answerText: String) -> CardBuilder {
        self.answerText = answerText
        return self
    }

    func withAnswerImageURL(_ answerImageURL: URL) -> CardBuilder {
        self.answerImageURL = answerImageURL
        return self
    }

    func withIsLearned(_ isLearned: Bool) -> CardBuilder {
        self.isLearned = isLearned
        return self
    }

    func build() -> Card {
        return Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
    }
}

final class PPOCardRepositoryUnitTests: XCTestCase {

    var cardRepository: CoreDataCardRepository!
    var mockDB: MockCoreDataManager!
    let context = NSPersistentContainer(name: "DataBasePPOCardsUnitTests").viewContext

    override func setUp() {
        ModelProvider.shared.setupDB(type: .CoreData)
        super.setUp()
        mockDB = MockCoreDataManager()
        mockDB.registerResult(for: \.fetchRef) { args in
            let res = SettingsMO(context: self.context)
            res.isMixed = false
            res.mixingInPower = 0
            return [res]
        }
        cardRepository = CoreDataCardRepository(customDataManager: mockDB)
    }

    override func tearDown() {
        cardRepository = nil
        super.tearDown()
    }

    func test_Unit_DB_GetCard() {
        feature("Тест получения карточки по ID")

        // Arrange
        let testCard = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(false)
            .build()
        
        mockDB.registerResult(for: \.fetchRef) { args in
            var res = CardMO(context: self.context)
            res = testCard.toCoreData(createdCardMO: res)
            return [res]
        }

        // Act
        let result = cardRepository.getCard(ID: testCard.id)

        // Assert
        step("Проверка совпадения тестовой карточки и карточки из БД") {
            XCTAssertNotNil(result)
            XCTAssertEqual(result, testCard)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_DB_AddCard() {
        feature("Тест добавления карточки")

        // Arrange
        let testCard = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(false)
            .build()

        mockDB.registerResult(for: \.createRef) { args in }

        // Act
        let result = cardRepository.addCard(card: testCard)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertTrue(result)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.createRef, numberOfTimes: 2))
        }
    }

    func test_Unit_DB_UpdateCard() {
        feature("Тест обновления карточки")

        // Arrange
        let cardAfterUpdate = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(true)
            .build()

        mockDB.registerResult(for: \.updateRef) { args in }

        // Act
        let updateRC = cardRepository.updateCard(oldID: UUID(), newCard: cardAfterUpdate)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(updateRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_DB_DeleteCard() {
        feature("Тест удаления карточки")

        // Arrange
        mockDB.registerResult(for: \.deleteRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            let res = CardMO(context: self.context)
            return [res]
        }

        // Act
        let removeRC = cardRepository.deleteCard(ID: UUID())

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(removeRC, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteRef))
        }
    }

    func test_Unit_DB_GetCardProgress() {
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
        let result = cardRepository.getCardProgress(cardSetID: cardSetId, cardID: cardId)

        // Assert
        step("Проверка совпадения тестового прогресса и полученного") {
            XCTAssertEqual(result, expectedRes)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_DB_ShareCardToSet() {
        feature("Тест шаринга карточки в другой набор")

        // Arrange
        let setIdToShare = UUID()
        let testCard = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(false)
            .build()

        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardMO(context: self.context)
            res.id = testCard.id
            res.setID = testCard.setID
            res.isLearned = testCard.isLearned
            return [res]
        }

        // Act
        let shareResult = cardRepository.shareCardToSet(cardID: testCard.id, newSetID: setIdToShare)

        // Assert
        step("Проверка совпадения setID перемещенной карточки с целевым") {
            XCTAssertEqual(shareResult?.setID, setIdToShare)
        }
    }

    func test_Unit_DB_DeleteAllCards() {
        feature("Тест удаления всех карточек")

        // Arrange
        mockDB.registerResult(for: \.deleteAllRef) { args in }
        mockDB.registerResult(for: mockDB.fetchRef) { args in
            let res = CardMO(context: self.context)
            return [res]
        }

        // Act
        cardRepository.deleteAllCards()

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.deleteAllRef))
        }
    }

    func test_Unit_DB_MarkAsLearned() {
        feature("Тест пометки карточки как выученной")

        // Arrange
        let testCard = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(false)
            .build()

        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardMO(context: self.context)
            res.id = testCard.id
            res.setID = testCard.setID
            res.isLearned = testCard.isLearned
            return [res]
        }
        mockDB.registerResult(for: mockDB.updateRef) { args in }

        // Act
        cardRepository.markAsLearned(cardID: testCard.id)

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_DB_MarkAsNotLearned() {
        feature("Тест пометки карточки как невыученной")

        // Arrange
        let testCard = CardBuilder()
            .withId(UUID())
            .withSetID(UUID())
            .withIsLearned(false)
            .build()

        mockDB.registerResult(for: \.fetchRef) { args in
            let res = CardMO(context: self.context)
            res.id = testCard.id
            res.setID = testCard.setID
            res.isLearned = testCard.isLearned
            return [res]
        }
        mockDB.registerResult(for: mockDB.updateRef) { args in }

        // Act
        cardRepository.markAsLearned(cardID: testCard.id)

        // Assert
        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }
}
