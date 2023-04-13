//
//  PPOSettingsRepositoryIntegrationTests.swift
//  PPOcardsIntegrationTests
//
//  Created by Сергей Николаев on 09.04.2023.
//

import XCTest
@testable import PPOcards

final class PPOSettingsRepositoryIntegrationTests: XCTestCase {

    private let db = UserDefaults.standard

    func test_createSettings() {
        let settingsRepository = CoreDataSettingsRepository()

        let rc = settingsRepository.createSettings()
        XCTAssertEqual(rc, true)

        XCTAssertEqual(db.bool(forKey: "SettingsIsMixed"), false)
        XCTAssertEqual(db.integer(forKey: "SettingsMixingInPower"), 0)
    }

    func test_getSettings() {
        let settingsRepository = CoreDataSettingsRepository()

        db.set(true, forKey: "SettingsIsMixed")
        db.set(55, forKey: "SettingsMixingInPower")

        let res = settingsRepository.getSettings()
        XCTAssertEqual(Settings(isMixed: true, mixingInPower: 55), res)
    }

    func test_updateSettings() {
        let settingsRepository = CoreDataSettingsRepository()

        db.set(true, forKey: "SettingsIsMixed")
        db.set(55, forKey: "SettingsMixingInPower")

        let rc = settingsRepository.updateSettings(to: Settings(isMixed: false, mixingInPower: 13))
        XCTAssertEqual(rc, true)

        XCTAssertEqual(db.bool(forKey: "SettingsIsMixed"), false)
        XCTAssertEqual(db.integer(forKey: "SettingsMixingInPower"), 13)
    }

    func test_updateSettings_withoutMixingIn() {
        let settingsRepository = CoreDataSettingsRepository()

        db.set(true, forKey: "SettingsIsMixed")
        db.set(55, forKey: "SettingsMixingInPower")

        let rc = settingsRepository.updateSettings(to: Settings(isMixed: false))
        XCTAssertEqual(rc, true)

        XCTAssertEqual(db.bool(forKey: "SettingsIsMixed"), false)
        XCTAssertEqual(db.integer(forKey: "SettingsMixingInPower"), 0)
    }

}
