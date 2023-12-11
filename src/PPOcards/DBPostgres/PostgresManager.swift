//
//  PostgresManager.swift
//  DBPostgres
//
//  Created by ser.nikolaev on 01.11.2023.
//

import PostgresClientKit

final class PostgresManager {

    static let shared: PostgresManager = PostgresManager()
    let connection: Connection

    private init() {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = ProcessInfo.processInfo.environment["PG_USER_HOST"] ?? "127.0.0.1"
            configuration.port = Int(ProcessInfo.processInfo.environment["PG_USER_PORT"] ?? "5432") ?? 5432
            configuration.database = ProcessInfo.processInfo.environment["PG_USER_DATABASE"] ?? "webdb"
            configuration.user = ProcessInfo.processInfo.environment["PG_USER_NAME"] ?? "web_admin"
            configuration.credential = .scramSHA256(password: ProcessInfo.processInfo.environment["PG_USER_PASSWORD"] ?? "web_admin")
            configuration.ssl = false

            connection = try PostgresClientKit.Connection(configuration: configuration)
            if ProcessInfo.processInfo.environment["CREATE_ENTITIES"] == "true" {
                try createTablesIfNeeded(connection: connection)
            }
        } catch {
            print("Error: \(error)")
            fatalError()
        }
    }

    func createTablesIfNeeded(connection: Connection) throws {
        var statement = try connection.prepareStatement(text: """
            CREATE TABLE IF NOT EXISTS settings (
                isMixed BOOLEAN NOT NULL,
                mixingInPower INTEGER
            );
        """)
        try statement.execute()
        statement = try connection.prepareStatement(text: """
            CREATE TABLE IF NOT EXISTS cardsets (
                _id UUID PRIMARY KEY,
                title TEXT NOT NULL,
                allCardsCount INTEGER NOT NULL,
                learnedCardsCount INTEGER NOT NULL,
                color INTEGER NOT NULL
            );
        """)
        try statement.execute()
        statement = try connection.prepareStatement(text: """
            CREATE TABLE IF NOT EXISTS cards (
                _id UUID PRIMARY KEY,
                setID UUID,
                questionText TEXT,
                questionImageURL TEXT,
                answerText TEXT,
                answerImageURL TEXT,
                isLearned BOOLEAN NOT NULL
            );
        """)
        try statement.execute()
        statement = try connection.prepareStatement(text: """
            CREATE TABLE IF NOT EXISTS cardprogress (
                _id SERIAL PRIMARY KEY,
                cardSetId UUID NOT NULL,
                cardId UUID NOT NULL,
                successCount INTEGER NOT NULL,
                allAttemptsCount INTEGER NOT NULL
            );
        """)
        try statement.execute()
    }

    deinit {
        connection.close()
    }

}

