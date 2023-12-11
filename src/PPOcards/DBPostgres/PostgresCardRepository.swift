//
//  PostgresCardRepository.swift
//  DBPostgres
//
//  Created by ser.nikolaev on 01.11.2023.
//

import Core
import PostgresClientKit

public class PostgresCardRepository: CardRepositoryDescription {

    let postgresDataManager = PostgresManager.shared
    let connection = PostgresManager.shared.connection

    public init() {}

    public func getCard(ID: UUID) -> Core.Card? {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cards WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [ID.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let setID: UUID? = try? UUID(uuidString: columns[1].optionalString() ?? "")
                let questionText: String? = try columns[2].optionalString()
                let questionImageURL: URL? = try URL(fileURLWithPath: columns[3].optionalString() ?? "")
                let answerText: String? = try columns[4].optionalString()
                let answerImageURL: URL? = try URL(fileURLWithPath: columns[5].optionalString() ?? "")
                let isLearned: Bool = try columns[6].bool()

                return Core.Card(id: id, setID: setID, questionText: questionText, questionImageURL: questionImageURL, answerText: answerText, answerImageURL: answerImageURL, isLearned: isLearned)
            } else {
                return nil
            }
        } catch {
            print("Error getting card: \(error)")
            return nil
        }
    }

    public func addCard(card: Core.Card) -> Bool {
        do {
            var insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            var parameters: [PostgresValueConvertible] = [
                card.id.uuidString,
                card.setID?.uuidString,
                card.questionText,
                card.questionImageURL?.path,
                card.answerText,
                card.answerImageURL?.path,
                card.isLearned
            ]

            try insertStatement.execute(parameterValues: parameters)

            insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cardprogress (cardSetId, cardId, successCount, allAttemptsCount)
                VALUES ($1, $2, $3, $4);
            """)

            parameters = [
                card.setID?.uuidString ?? "",
                card.id.uuidString,
                Int(),
                Int()
            ]

            try insertStatement.execute(parameterValues: parameters)

            return true
        } catch {
            print("Failed to add card: \(error)")
            return false
        }
    }


    public func updateCard(oldID: UUID, newCard: Core.Card) -> Bool {
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE cards
                SET setID = $1, questionText = $2, questionImageURL = $3, answerText = $4, answerImageURL = $5, isLearned = $6
                WHERE _id = $7;
            """)

            let parameters: [PostgresValueConvertible] = [
                newCard.setID?.uuidString,
                newCard.questionText,
                newCard.questionImageURL?.path,
                newCard.answerText,
                newCard.answerImageURL?.path,
                newCard.isLearned,
                oldID.uuidString
            ]

            try statement.execute(parameterValues: parameters)
            return true
        } catch {
            print("Failed to update card: \(error)")
            return false
        }
    }


    public func deleteCard(ID: UUID) -> Bool {
        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cards WHERE _id = $1;
            """)
            try statement.execute(parameterValues: [ID.uuidString])
            return true
        } catch {
            print("Failed to delete card set: \(error)")
            return false
        }
    }

    public func getCardProgress(cardSetID: UUID, cardID: UUID) -> Core.CardProgress? {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cardprogress WHERE cardSetId = $1 AND cardId = $2;
            """)
            let cursor = try statement.execute(parameterValues: [cardSetID.uuidString, cardID.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let cardSetId: UUID = try UUID(uuidString: columns[1].string())!
                let cardId: UUID = try UUID(uuidString: columns[2].string())!
                let successCount: Int = try columns[3].int()
                let allAttemptsCount: Int = try columns[4].int()

                return Core.CardProgress(cardSetId: cardSetId, cardId: cardId, successCount: successCount, allAttemptsCount: allAttemptsCount)
            } else {
                return nil
            }
        } catch {
            print("Error getting card: \(error)")
            return nil
        }
    }

    public func shareCardToSet(cardID: UUID, newSetID: UUID) -> Bool {
        guard let card = getCard(ID: cardID) else { return false }

        return addCard(card: Card(id: UUID(), setID: newSetID, questionText: card.questionText, questionImageURL: card.questionImageURL, answerText: card.answerText, answerImageURL: card.answerImageURL, isLearned: false))
    }

    public func deleteAllCards() {
        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cards;
            """)

            try statement.execute()
        } catch {

        }
    }

    public func markAsLearned(cardID: UUID) {
        do {
            var statement = try connection.prepareStatement(text: """
                UPDATE cards
                SET isLearned = true
                WHERE _id = $1;
            """)

            let parameters: [PostgresValueConvertible] = [cardID.uuidString]

            try statement.execute(parameterValues: parameters)

            statement = try connection.prepareStatement(text: """
                UPDATE cardprogress
                SET allAttemptsCount = allAttemptsCount + 1, successCount = successCount + 1
                WHERE cardId = $1;
            """)

            try statement.execute(parameterValues: parameters)
        } catch {
            print("Failed to update card: \(error)")
        }
    }

    public func markAsNotLearned(cardID: UUID) {
        do {
            var statement = try connection.prepareStatement(text: """
                UPDATE cards
                SET isLearned = false
                WHERE _id = $1;
            """)

            let parameters: [PostgresValueConvertible] = [cardID.uuidString]

            try statement.execute(parameterValues: parameters)

            statement = try connection.prepareStatement(text: """
                UPDATE cardprogress
                SET allAttemptsCount = allAttemptsCount + 1
                WHERE cardId = $1;
            """)

            try statement.execute(parameterValues: parameters)
        } catch {
            print("Failed to update card: \(error)")
        }
    }


}
