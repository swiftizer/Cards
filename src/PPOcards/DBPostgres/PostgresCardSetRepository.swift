//
//  PostgresCardSetRepository.swift
//  DBPostgres
//
//  Created by ser.nikolaev on 01.11.2023.
//

import Core
import PostgresClientKit

public class PostgresCardSetRepository: CardSetRepositoryDescription {

    let postgresDataManager = PostgresManager.shared
    let connection = PostgresManager.shared.connection

    public init() {}

    public func getCardSet(ID: UUID) -> Core.CardSet? {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT * FROM cardsets WHERE _id = $1;
            """)
            let cursor = try statement.execute(parameterValues: [ID.uuidString])

            if let columns = try cursor.next()?.get().columns {
                let id: UUID = try UUID(uuidString: columns[0].string())!
                let title: String = try columns[1].string()
                let allCardsCount: Int = try columns[2].int()
                let learnedCardsCount: Int = try columns[3].int()
                let color: Int = try columns[4].int()

                return Core.CardSet(id: id, title: title, allCardsCount: allCardsCount, learnedCardsCount: learnedCardsCount, color: color)
            } else {
                return nil
            }
        } catch {
            print("Error getting card set: \(error)")
            return nil
        }
    }


    public func addCardSet(set: Core.CardSet) -> Bool {
        do {
            let statement = try connection.prepareStatement(text: """
                INSERT INTO cardsets (_id, title, allCardsCount, learnedCardsCount, color)
                VALUES ($1, $2, $3, $4, $5);
            """)

            let parameters: [PostgresValueConvertible] = [
                set.id.uuidString,
                set.title,
                set.allCardsCount,
                set.learnedCardsCount,
                set.color
            ]

            try statement.execute(parameterValues: parameters)

            return true
        } catch {
            print("Failed to add card set: \(error)")
            return false
        }
    }

    public func getAllCardSetIDs() -> [UUID] {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT _id FROM cardsets;
            """)

            let cursor = try statement.execute()

            var ids = [UUID]()
            for row in cursor {
                let columns = try row.get().columns
                let id: UUID = try UUID(uuidString: columns[0].string())!
                ids.append(id)
            }

            return ids
        } catch {
            return []
        }
    }


    public func getAllCardIDsFromSet(setID: UUID) -> [UUID] {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT _id FROM cards WHERE setID = $1;
            """)

            let rows = try statement.execute(parameterValues: [setID.uuidString])

            var cardIDs: [UUID] = []
            for row in rows {
                let columns = try row.get().columns
                let id: UUID = try UUID(uuidString: columns[0].string())!
                cardIDs.append(id)
            }

            return cardIDs
        } catch {
            return []
        }
    }

    public func getNotLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT _id FROM cards WHERE setID = $1 AND isLearned = $2;
            """)

            let rows = try statement.execute(parameterValues: [setID.uuidString, false])

            var cardIDs: [UUID] = []
            for row in rows {
                let columns = try row.get().columns
                let id: UUID = try UUID(uuidString: columns[0].string())!
                cardIDs.append(id)
            }

            return cardIDs
        } catch {
            return []
        }
    }

    public func getLearnedCardIDsFromSet(from setID: UUID) -> [UUID] {
        do {
            let statement = try connection.prepareStatement(text: """
                SELECT _id FROM cards WHERE setID = $1 AND isLearned = $2;
            """)

            let rows = try statement.execute(parameterValues: [setID.uuidString, true])

            var cardIDs: [UUID] = []
            for row in rows {
                let columns = try row.get().columns
                let id: UUID = try UUID(uuidString: columns[0].string())!
                cardIDs.append(id)
            }

            return cardIDs
        } catch {
            return []
        }
    }

    public func addCard(card: Core.Card, toSet cardSetID: UUID) -> Bool {
        do {
            let insertStatement = try connection.prepareStatement(text: """
                INSERT INTO cards (_id, setID, questionText, questionImageURL, answerText, answerImageURL, isLearned)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
            """)

            let parameters: [PostgresValueConvertible] = [
                card.id.uuidString,
                cardSetID.uuidString,
                card.questionText,
                card.questionImageURL?.path,
                card.answerText,
                card.answerImageURL?.path,
                card.isLearned
            ]

            try insertStatement.execute(parameterValues: parameters)

            return true
        } catch {
            print("Failed to add card: \(error)")
            return false
        }
    }

    public func deleteCardSet(ID: UUID) -> Bool {
        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cardsets WHERE _id = $1;
            """)
            try statement.execute(parameterValues: [ID.uuidString])
            return true
        } catch {
            print("Failed to delete card set: \(error)")
            return false
        }
    }

    public func deleteAllCardSets() {
        do {
            let statement = try connection.prepareStatement(text: """
                DELETE FROM cardsets;
            """)

            try statement.execute()
        } catch {

        }
    }

    public func updateCardSet(oldID: UUID, newSet: CardSet) -> Bool {
        do {
            let statement = try connection.prepareStatement(text: """
                UPDATE cardsets
                SET title = $1, allCardsCount = $2, learnedCardsCount = $3, color = $4
                WHERE _id = $5
            """)
            let parameters: [PostgresValueConvertible] = [
                newSet.title,
                newSet.allCardsCount,
                newSet.learnedCardsCount,
                newSet.color,
                oldID.uuidString
            ]

            try statement.execute(parameterValues: parameters)

            return true
        } catch {
            print("Failed to update card set: \(error)")
            return false
        }
    }

}
