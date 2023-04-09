//
//  SettingsController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import UIKit


class SettingsController: SettingsControllerDescription {
    private let dataSource: SettingsRepositoryDescription
    weak var cardSetController: CardSetControllerDescription?

    init(dataSource: SettingsRepositoryDescription) {
        self.dataSource = dataSource
    }

    func getSettings() -> Settings {
        return dataSource.getSettings()
    }

    func updateSettings(to newSettings: Settings) -> Bool {
        var newSettingsCorrect = newSettings

        if newSettings.mixingInPower ?? 0 < 0 {
            newSettingsCorrect.mixingInPower = 0
        } else if newSettings.mixingInPower ?? 0 > 100 {
            newSettingsCorrect.mixingInPower = 100
        }

        cardSetController?.settings = newSettingsCorrect
        return dataSource.updateSettings(to: newSettingsCorrect)
    }
}
