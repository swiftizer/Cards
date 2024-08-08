//
//  PPOCardRepositoryIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
import FileManager
import PostgresClientKit
@testable import Core
@testable import DBPostgres

final class PPOCardControllerIntegrationTests: XCTestCase {

    private let db = PostgresManager.shared
    private var cardController: CardController!
    let connection = PostgresManager.shared.connection

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    override func setUp() {
        let cardRepository = PostgresCardRepository()
        cardController = CardController(dataSource: cardRepository,
                                        cardSetController: 
                                            CardSetController(dataSource: PostgresCardSetRepository(),
                                                              settingsController:
                                                                SettingsController(dataSource:PostgresSettingsRepository())))
    }

    func test_Int_BL_getCard() {
        feature("Тест получения карточки по ID")

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters = card.toParamsArray()

            try insertStatement.execute(parameterValues: parameters)

            let res = cardController.getCard(ID: id)
            step("Проверка совпадения тестовой карточки и карточки из БД") {
                XCTAssertEqual(card, res)
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_BL_createCard() {
        feature("Тест создания карточки")

        let id = UUID()
        let id1 = UUID()
        let card = Card(id: id, setID: id1, isLearned: true)

        let card1 = cardController.createCard(for: id1)

        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [card1.id.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                let cardRes = Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
                step("Проверка совпадения setID тестовой карточки с этолонным") {
                    XCTAssertEqual(card1, cardRes)
                    XCTAssertEqual(id1, cardRes.setID)
                }

            } else {
                XCTFail()
            }
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_BL_updateCard() {
        feature("Тест обновления карточки")

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)
        let id1 = UUID()
        let card1 = Card(id: id, setID: id1, isLearned: false)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters = card.toParamsArray()

            try insertStatement.execute(parameterValues: parameters)

            let rc = cardController.updateCard(oldID: id, new: card1)
            step("Проверка успешности кода возврата") {
                XCTAssertEqual(rc, true)
            }

            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [card.id.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                let cardRes = Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
                step("Проверка успешности обновления") {
                    XCTAssertEqual(card1, cardRes)
                }

            } else {
                XCTFail()
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_BL_deleteCard() {
        feature("Тест удаления карточки")

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)

        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cards;
            """)

            try statement.execute()

            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters = card.toParamsArray()

            try insertStatement.execute(parameterValues: parameters)

            let statement1 = try connection.prepareStatement(text: """
                SELECT COUNT(*) FROM cards;
            """)

            var cursor = try statement1.execute()
            var count = try cursor.next()?.get().columns[0].int()

            step("Проверка успешности создания") {
                XCTAssertEqual(count, 1)
            }

            let rc = cardController.deleteCard(ID: id)
            step("Проверка успешности кода возврата") {
                XCTAssertEqual(rc, true)
            }

            cursor = try statement1.execute()
            count = try cursor.next()?.get().columns[0].int()

            step("Проверка успешности удаления") {
                XCTAssertEqual(count, 0)
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_deleteAllCards() {
        feature("Тест удаления всех карточек")

        let id = UUID()
        let id1 = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)
        let card1 = Card(id: id1, setID: nil, isLearned: true)

        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cards;
            """)

            try statement.execute()

            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            try insertStatement.execute(parameterValues: card.toParamsArray())
            try insertStatement.execute(parameterValues: card1.toParamsArray())

            let statement1 = try connection.prepareStatement(text: """
                SELECT COUNT(*) FROM cards;
            """)

            var cursor = try statement1.execute()
            var count = try cursor.next()?.get().columns[0].int()

            step("Проверка успешности создания") {
                XCTAssertEqual(count, 2)
            }

            cardController.deleteAllCards()

            cursor = try statement1.execute()
            count = try cursor.next()?.get().columns[0].int()

            step("Проверка успешности удаления") {
                XCTAssertEqual(count, 0)
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_markAsLearned() {
        feature("Тест пометки карточки как выученной")

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: false)
        let cardRef = Card(id: id, setID: nil, isLearned: true)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters = card.toParamsArray()

            try insertStatement.execute(parameterValues: parameters)

            cardController.markAsLearned(cardID: card.id)

            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [card.id.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                let cardRes = Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
                step("Проверка успешности пометки") {
                    XCTAssertEqual(cardRes, cardRef)
                }

            } else {
                XCTFail()
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_BL_markAsNotLearned() {
        feature("Тест пометки карточки как невыученной")

        let id = UUID()
        let card = Card(id: id, setID: nil, isLearned: true)
        let cardRef = Card(id: id, setID: nil, isLearned: false)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters = card.toParamsArray()

            try insertStatement.execute(parameterValues: parameters)

            cardController.markAsNotLearned(cardID: card.id)

            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [card.id.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                let cardRes = Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
                step("Проверка успешности пометки") {
                    XCTAssertEqual(cardRes, cardRef)
                }

            } else {
                XCTFail()
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }
}
