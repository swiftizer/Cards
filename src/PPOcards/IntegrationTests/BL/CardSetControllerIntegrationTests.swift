//
//  PPOcardsIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
import FileManager
import PostgresClientKit
@testable import Core
@testable import DBPostgres

final class PPOCardSetControllerIntegrationTests: XCTestCase {

    private let db = PostgresManager.shared
    private var cardSetController: CardSetController!
    let connection = PostgresManager.shared.connection

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    override func setUp() {
        let cardSetRepository = PostgresCardSetRepository()
        cardSetController = CardSetController(dataSource: cardSetRepository, settingsController: SettingsController(dataSource: PostgresSettingsRepository()))
    }

    func test_Int_BL_getAllCardSets() {
        feature("Тест получения всех наборов карточек")

        let id1 = UUID()
        let id2 = UUID()
        let set1 = CardSet(id: id1, title: "test_Int_BL_GetCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)
        let set2 = CardSet(id: id2, title: "test_Int_BL_GetCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)

        do {
            var statement = try connection.prepareStatement(text: """
                DELETE FROM cardsets;
            """)

            try statement.execute()

            statement = try connection.prepareStatement(text: """
                INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
                VALUES ($1, $2, $3, $4, $5);
            """)

            try statement.execute(parameterValues: set1.toParamsArray())
            try statement.execute(parameterValues: set2.toParamsArray())

            let res = cardSetController.getAllCardSets()
            step("Проверка находжения всех созданных наборов в результате") {
                XCTAssertEqual(res.count, 2)
                XCTAssertTrue(res.contains(set1))
                XCTAssertTrue(res.contains(set2))
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_GetCardSet() {
        feature("Тест получения набора карточек по ID")

        let id = UUID()
        let set = CardSet(id: id, title: "test_Int_BL_GetCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
                VALUES ($1, $2, $3, $4, $5);
            """)

            try statement.execute(parameterValues: set.toParamsArray())

            let res = cardSetController.getCardSet(ID: id)
            step("Проверка совпадения тестового набора и эталонного") {
                XCTAssertEqual(set, res)
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_createCardSet() {
        feature("Тест создания набора карточек")

        let id = UUID()
        let set = CardSet(id: id, title: "test_Int_BL_addCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)
        let csREF = cardSetController.createCardSet(title: set.title)

        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cardsets WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [csREF.id.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let title: String = try columns[1].string()
                let allCardsCount: Int = try columns[2].int()
                let learnedCardsCount: Int = try columns[3].int()
                let color: Int = try columns[4].int()

                let cardSet = Core.CardSet(id: id, title: title, allCardsCount: allCardsCount, learnedCardsCount: learnedCardsCount, color: color)
                step("Проверка возврата созданного набора") {
                    XCTAssertEqual(csREF, cardSet)
                    XCTAssertEqual(csREF.title, set.title)
                }

            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_addCard() {
        feature("Тест добавления карточки в набор")

        let id1 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)

        let rc = cardSetController.addCard(card: card1, toSet: id3)
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [id1.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                let cardRes = Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
                step("Проверка успешности добавления") {
                    XCTAssertEqual(card1, cardRes)
                }

            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_getAllCardIDsFromSet() {
        feature("Тест получения всех карточек из набора")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            try insertStatement.execute(parameterValues: card1.toParamsArray())
            try insertStatement.execute(parameterValues: card2.toParamsArray())

            let res = cardSetController.getAllCardIDsFromSet(from: id3)
            step("Проверка совпадения полученных наборов карточек с ожидаемыми") {
                XCTAssertEqual(Set([id1, id2]), Set(res))
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_getNotLearnedCardIDsFromSet() {
        feature("Тест получения невыученных карточек из набора")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            try insertStatement.execute(parameterValues: card1.toParamsArray())
            try insertStatement.execute(parameterValues: card2.toParamsArray())

            let res = cardSetController.getNotLearnedCardIDsFromSet(from: id3)
            step("Проверка совпадения полученных наборов с ожидаемым") {
                XCTAssertEqual(Set([id2]), Set(res))
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_getLearnedCardIDsFromSet() {
        feature("Тест получения выученных карточек из набора")

        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let card1 = Card(id: id1, setID: id3, isLearned: true)
        let card2 = Card(id: id2, setID: id3, isLearned: false)

        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            try insertStatement.execute(parameterValues: card1.toParamsArray())
            try insertStatement.execute(parameterValues: card2.toParamsArray())

            let res = cardSetController.getLearnedCardIDsFromSet(from: id3)
            step("Проверка совпадения тестовой выученной карточки и полученной") {
                XCTAssertEqual(Set([id1]), Set(res))
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_updateCardSet() {
        feature("Тест обновления набора карточек")

        let idOld = UUID()
        let idNew = UUID()

        let csOld = CardSet(id: idOld, title: "deleteCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)
        let csNew = CardSet(id: idNew, title: "deleteCardSetN", allCardsCount: 10, learnedCardsCount: 5, color: 0x0B00FF)
        let csREF = CardSet(id: idOld, title: "deleteCardSetN", allCardsCount: 10, learnedCardsCount: 5, color: 0x0B00FF)

        do {
            var statement = try connection.prepareStatement(text: """
                INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
                VALUES ($1, $2, $3, $4, $5);
            """)

            try statement.execute(parameterValues: csOld.toParamsArray())

            let rc = cardSetController.updateCardSet(oldID: csOld.id, new: csNew)
            step("Проверка успешности кода возврата") {
                XCTAssertEqual(rc, true)
            }

            statement = try connection.prepareStatement(text: """
                SELECT * FROM cardsets WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [idOld.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let title: String = try columns[1].string()
                let allCardsCount: Int = try columns[2].int()
                let learnedCardsCount: Int = try columns[3].int()
                let color: Int = try columns[4].int()

                let cardSet = Core.CardSet(id: id, title: title, allCardsCount: allCardsCount, learnedCardsCount: learnedCardsCount, color: color)
                step("Проверка успешности обновления") {
                    XCTAssertEqual(cardSet, csREF)
                }

            } else {
                XCTFail()
            }

        } catch {
            XCTFail()
        }
    }

    func test_Int_BL_deleteCardSet() {
        feature("Тест удаления набора карточек")

        let id = UUID()
        let cs = CardSet(id: id, title: "deleteCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0x0000FF)

        do {
            var statement = try connection.prepareStatement(text: """
                INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
                VALUES ($1, $2, $3, $4, $5);
            """)

            try statement.execute(parameterValues: cs.toParamsArray())

            let rc = cardSetController.deleteCardSet(ID: id)
            step("Проверка успешности кода возврата") {
                XCTAssertEqual(rc, true)
            }

            statement = try connection.prepareStatement(text: """
                SELECT COUNT(*) FROM cardsets WHERE _id = $1;
            """)

            let cursor = try statement.execute(parameterValues: [id.uuidString])
            let count = try cursor.next()?.get().columns[0].int()

            step("Проверка успешности удаления") {
                XCTAssertEqual(count, 0)
            }

        } catch {
            XCTFail()
        }
    }
}

