//
//  PPOSettingsTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 30.03.2023.
//

import XCTest
import Services
import DBCoreData
import CoreData
import MockingKit
@testable import Core

final class SettingsRepositoryMock: Mock, SettingsRepositoryDescription {
    lazy var getRef = MockReference(getSettings)
    lazy var updateRef = MockReference(updateSettings)

    func getSettings() -> Settings {
        call(getRef, args: ())
    }

    func updateSettings(to newSettings: Settings) -> Bool {
        call(updateRef, args: (newSettings))
    }
}


final class PPOSettingsControllerUnitTests: XCTestCase {

    var settingsController: SettingsController!
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
        settingsController = SettingsController(dataSource: CoreDataSettingsRepository(customDataManager: mockDB))
    }

    override func tearDown() {
        settingsController = nil
        super.tearDown()
    }

    private func londonSetUp() -> SettingsRepositoryMock {
        let mockedRepository = SettingsRepositoryMock()
        settingsController = SettingsController(dataSource: mockedRepository)
        return mockedRepository
    }

    func test_Unit_BL_getSettings() {
        feature("Тест получения настроек")

        // Arrange
        let testSettings = SettingsFabric.getSettings()
        mockDB.registerResult(for: \.fetchRef) { args in
            var res = SettingsMO(context: self.context)
            res = testSettings.toCoreData(settingsMO: res)
            return [res]
        }

        // Act
        let result = settingsController.getSettings()

        // Assert
        step("Проверка совпадения полученных настроек с ожмдаемыми") {
            XCTAssertEqual(result, testSettings)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.fetchRef))
        }
    }

    func test_Unit_BL_getSettingsLondon() {
        feature("Тест получения настроек (London)")

        // Arrange
        let mockedRepository = londonSetUp()
        let testSettings = SettingsFabric.getSettings()
        mockedRepository.registerResult(for: \.getRef) { args in testSettings }

        // Act
        let result = settingsController.getSettings()

        // Assert
        step("Проверка совпадения полученных настроек с ожмдаемыми") {
            XCTAssertEqual(result, testSettings)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockedRepository.hasCalled(\.getRef))
        }
    }

    func test_Unit_BL_updateSettings() {
        feature("Тест обновления настроек")

        // Arrange
        let testUpdatedSettings = SettingsFabric.getUpdatedSettingsStandart()
        mockDB.registerResult(for: \.updateRef) { args in }

        // Act
        let rc = settingsController.updateSettings(to: testUpdatedSettings)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        step("Проверка вызова необходимого метода") {
            XCTAssertTrue(mockDB.hasCalled(\.updateRef))
        }
    }

    func test_Unit_BL_UpdateSettingsLondon() {
        feature("Тест обновления настроек (London)")

        // Arrange
        let mockedRepository = londonSetUp()
        let testSettings = SettingsFabric.getUpdatedSettingsStandart()
        mockedRepository.registerResult(for: \.updateRef) { args in true }

        // Act
        let rc = settingsController.updateSettings(to: testSettings)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        step("Проверка несовпадения настроек до и после обновления") {
            XCTAssertEqual(mockedRepository.calls(to: \.updateRef).first?.arguments, testSettings)
        }
    }

    func test_Unit_BL_UpdateSettingsLessLondon() {
        feature("Тест обновления настроек (London)")

        // Arrange
        let mockedRepository = londonSetUp()
        let testSettings = SettingsFabric.getUpdatedSettingsLess()
        let expectedSettings = SettingsFabric.getUpdatedSettingsMin()
        mockedRepository.registerResult(for: \.updateRef) { args in true }

        // Act
        let rc = settingsController.updateSettings(to: testSettings)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        step("Проверка несовпадения настроек до и после обновления") {
            XCTAssertEqual(mockedRepository.calls(to: \.updateRef).first?.arguments, expectedSettings)
        }
    }

    func test_Unit_BL_UpdateSettingsGreaterLondon() {
        feature("Тест обновления настроек (London)")

        // Arrange
        let mockedRepository = londonSetUp()
        let testSettings = SettingsFabric.getUpdatedSettingsGreater()
        let expectedSettings = SettingsFabric.getUpdatedSettingsMax()
        mockedRepository.registerResult(for: \.updateRef) { args in true }

        // Act
        let rc = settingsController.updateSettings(to: testSettings)

        // Assert
        step("Проверка успешности кода возврата") {
            XCTAssertEqual(rc, true)
        }

        step("Проверка несовпадения настроек до и после обновления") {
            XCTAssertEqual(mockedRepository.calls(to: \.updateRef).first?.arguments, expectedSettings)
        }
    }
}
