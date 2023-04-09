//
//  PPOcardsTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 28.03.2023.
//

import XCTest
@testable import PPOcards

final class PPOCardControllerUnitTests: XCTestCase {
    
    var cardController = CardController(dataSource: CoreDataCardRepository())

    private func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }

    func test_GetCard() {
        let testCard = cardController.createCard(for: setUUID(param: 0))

        XCTAssertEqual(cardController.getCard(ID: testCard.id), testCard)
    }

    func test_CreateCard() {
        let testCard = cardController.createCard(for: setUUID(param: 0))
        let testRefCard = Card(id: UUID(), setID: setUUID(param: 0), isLearned: false)

        XCTAssertEqual(testCard.setID, testRefCard.setID)
        XCTAssertEqual(testCard.isLearned, testRefCard.isLearned)
    }

    func test_DeleteCard() {
        XCTAssertEqual(cardController.deleteCard(ID: UUID()), true)
    }

    func test_UpdateCard() {
        XCTAssertEqual(cardController.updateCard(oldID: UUID(), new: Card(id: UUID(), setID: UUID(), isLearned: true)), true)
    }

}
