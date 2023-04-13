//
//  PPOSettingsTests.swift
//  PPOcardsTests
//
//  Created by Сергей Николаев on 30.03.2023.
//

import XCTest
@testable import PPOcards

final class PPOSettingsUnitTests: XCTestCase {

    var settingsController = SettingsController(dataSource: CoreDataSettingsRepository())

    func test_getSettings() {
        settingsController.updateSettings(to: Settings(isMixed: false, mixingInPower: 0))

        XCTAssertEqual(settingsController.getSettings(), Settings(isMixed: false, mixingInPower: 0))
    }

    func test_updateSettings() {
        XCTAssertEqual(settingsController.updateSettings(to: Settings(isMixed: true, mixingInPower: 10)), true)
    }

}
