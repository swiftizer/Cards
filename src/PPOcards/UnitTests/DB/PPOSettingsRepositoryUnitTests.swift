//
//  PPOSettingsRepositoryUnitTests.swift
//  UnitTests
//
//  Created by ser.nikolaev on 22.10.2023.
//

import XCTest
import Services
import CoreData
@testable import DBCoreData

final class PPOSettingsRepositoryUnitTests: XCTestCase {

    var settingsRepository: CoreDataSettingsRepository!
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
        settingsRepository = CoreDataSettingsRepository(customDataManager: mockDB)
    }

    override func tearDown() {
        settingsRepository = nil
        super.tearDown()
    }

    func test_Unit_DB_getSettings() {
        feature("Тест получения настроек")

        // Arrange
        let testSettings = SettingsFabric.getSettings()
        mockDB.registerResult(for: \.fetchRef) { args in
            var res = SettingsMO(context: self.context)
            res = testSettings.toCoreData(settingsMO: res)
            return [res]
        }

        // Act
        let result = settingsRepository.getSettings()

        // Assert
        step("Проверка совпадения полученных настроек с ожмдаемыми") {
            XCTAssertEqual(result, testSettings)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_DB_updateSettings() {
        feature("Тест обновления настроек")

        // Arrange
        let testUpdatedSettings = SettingsFabric.getUpdatedSettingsStandart()
        mockDB.registerResult(for: \.updateRef) { args in }

        // Act
        let rc = settingsRepository.updateSettings(to: testUpdatedSettings)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }
}
