//
//  PPOSettingsRepositoryIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
import PostgresClientKit
@testable import Core
@testable import DBPostgres

final class PPOSettingsRepositoryIntegrationTests: XCTestCase {

    private let db = PostgresManager.shared
    private var settingsRepository: PostgresSettingsRepository!
    let connection = PostgresManager.shared.connection

    override func setUp() {
        settingsRepository = PostgresSettingsRepository()
    }

    func test_Int_DB_getSettings() {
        feature("Тест получения настроек")

        let settings = Settings(isMixed: true, mixingInPower: 55)

        do {
            let checkStatement = try connection.prepareStatement(text: "SELECT COUNT(*) FROM settings;")
            let checkResult = try checkStatement.execute()
            let count = try checkResult.next()?.get().columns[0].int() ?? 0

            if count > 0 {
                let updateStatement = try connection.prepareStatement(text: """
                UPDATE settings SET isMixed = $1, mixingInPower = $2;
            """)
                try updateStatement.execute(parameterValues: settings.toParamsArray())
            } else {
                let insertStatement = try connection.prepareStatement(text: """
                INSERT INTO settings (isMixed, mixingInPower) VALUES ($1, $2);
            """)
                try insertStatement.execute(parameterValues: settings.toParamsArray())
            }

            let res = settingsRepository.getSettings()
            step("Проверка совпадения полученных настроек с ожмдаемыми") {
                XCTAssertEqual(settings, res)
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_DB_updateSettings() {
        feature("Тест обновления настроек")

        let settings = Settings(isMixed: true, mixingInPower: 55)
        let settings1 = Settings(isMixed: false, mixingInPower: 99)

        do {
            let checkStatement = try connection.prepareStatement(text: "SELECT COUNT(*) FROM settings;")
            let checkResult = try checkStatement.execute()
            let count = try checkResult.next()?.get().columns[0].int() ?? 0

            if count > 0 {
                let updateStatement = try connection.prepareStatement(text: """
                UPDATE settings SET isMixed = $1, mixingInPower = $2;
            """)
                try updateStatement.execute(parameterValues: settings.toParamsArray())
            } else {
                let insertStatement = try connection.prepareStatement(text: """
                INSERT INTO settings (isMixed, mixingInPower) VALUES ($1, $2);
            """)
                try insertStatement.execute(parameterValues: settings.toParamsArray())
            }

            settingsRepository.updateSettings(to: settings1)

            let text = "SELECT * FROM settings;"
            let statement = try connection.prepareStatement(text: text)
            let cursor = try statement.execute()

            let columns = try cursor.next()?.get().columns
            let isMixed = try columns?[0].bool() ?? false
            let mixingInPower = try columns?[1].optionalInt()

            let settingsRes = Settings(isMixed: isMixed, mixingInPower: mixingInPower)

            step("Проверка успешности обновления") {
                XCTAssertEqual(settings1, settingsRes)
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }

    func test_Int_DB_updateSettings_withoutMixingIn() {
        feature("Тест обновления настроек без подмешивания")

        let settings = Settings(isMixed: true)
        let settings1 = Settings(isMixed: false)

        do {
            let checkStatement = try connection.prepareStatement(text: "SELECT COUNT(*) FROM settings;")
            let checkResult = try checkStatement.execute()
            let count = try checkResult.next()?.get().columns[0].int() ?? 0

            if count > 0 {
                let updateStatement = try connection.prepareStatement(text: """
                UPDATE settings SET isMixed = $1, mixingInPower = $2;
            """)
                try updateStatement.execute(parameterValues: settings.toParamsArray())
            } else {
                let insertStatement = try connection.prepareStatement(text: """
                INSERT INTO settings (isMixed, mixingInPower) VALUES ($1, $2);
            """)
                try insertStatement.execute(parameterValues: settings.toParamsArray())
            }

            settingsRepository.updateSettings(to: settings1)

            let text = "SELECT * FROM settings;"
            let statement = try connection.prepareStatement(text: text)
            let cursor = try statement.execute()

            let columns = try cursor.next()?.get().columns
            let isMixed = try columns?[0].bool() ?? false
            let mixingInPower = try columns?[1].optionalInt()

            let settingsRes = Settings(isMixed: isMixed, mixingInPower: mixingInPower)

            step("Проверка успешности обновления") {
                XCTAssertEqual(settings1, settingsRes)
            }

        } catch {
            XCTFail("Exception thrown: \(error)")
        }
    }
}

fileprivate extension Settings {
    func toParamsArray() -> [(any PostgresValueConvertible)?] {
        [self.isMixed, self.mixingInPower]
    }
}
