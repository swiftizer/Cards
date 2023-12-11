//
//  PostgresSettingsRepository.swift
//  DBPostgres
//
//  Created by ser.nikolaev on 01.11.2023.
//

import Core

public class PostgresSettingsRepository: SettingsRepositoryDescription {

    let postgresDataManager = PostgresManager.shared
    let connection = PostgresManager.shared.connection

    public init() {
        do {
            let checkStatement = try connection.prepareStatement(text: "SELECT COUNT(*) FROM settings;")
            let checkResult = try checkStatement.execute()
            let count = try checkResult.next()?.get().columns[0].int() ?? 0

            if count == 0 {
                createSettings()
            }
        } catch {
            createSettings()
        }
    }

    func createSettings() -> Bool {
        do {
            let checkStatement = try connection.prepareStatement(text: "SELECT COUNT(*) FROM settings;")
            let checkResult = try checkStatement.execute()
            let count = try checkResult.next()?.get().columns[0].int() ?? 0

            if count > 0 {
                let updateStatement = try connection.prepareStatement(text: """
                UPDATE settings SET isMixed = $1, mixingInPower = $2;
            """)
                try updateStatement.execute(parameterValues: [false, 0])
            } else {
                let insertStatement = try connection.prepareStatement(text: """
                INSERT INTO settings (isMixed, mixingInPower) VALUES ($1, $2);
            """)
                try insertStatement.execute(parameterValues: [false, 0])
            }

            return true
        } catch {
            return false
        }
    }

    public func getSettings() -> Core.Settings {
        do {
            let text = "SELECT * FROM settings;"
            let statement = try connection.prepareStatement(text: text)
            let cursor = try statement.execute()

            let columns = try cursor.next()?.get().columns
            let isMixed = try columns?[0].bool() ?? false
            let mixingInPower = try columns?[1].optionalInt()

            return Settings(isMixed: isMixed, mixingInPower: mixingInPower)
        } catch {
            return Settings(isMixed: false)
        }
    }

    public func updateSettings(to newSettings: Core.Settings) -> Bool {
        do {
            let updateStatement = try connection.prepareStatement(text: """
            UPDATE settings SET isMixed = $1, mixingInPower = $2;
        """)
            try updateStatement.execute(parameterValues: [newSettings.isMixed, newSettings.mixingInPower])

            return true
        } catch {
            return false
        }
    }
}
