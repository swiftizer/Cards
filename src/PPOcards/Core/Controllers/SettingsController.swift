//
//  SettingsController.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import Foundation
import Logger


public class SettingsController: SettingsControllerDescription {
    private let dataSource: SettingsRepositoryDescription
    weak public var cardSetController: CardSetControllerDescription?

    public init(dataSource: SettingsRepositoryDescription) {
        Logger.shared.log(lvl: .VERBOSE, msg: "SettingsController inited")
        self.dataSource = dataSource
    }

    public func getSettings() -> Settings {
        Logger.shared.log(lvl: .DEBUG, msg: "User gets settings")
        return dataSource.getSettings()
    }

    public func updateSettings(to newSettings: Settings) -> Bool {
        var newSettingsCorrect = newSettings

        if newSettings.mixingInPower ?? 0 < 0 {
            newSettingsCorrect.mixingInPower = 0
        } else if newSettings.mixingInPower ?? 0 > 100 {
            newSettingsCorrect.mixingInPower = 100
        }

        cardSetController?.settings = newSettingsCorrect
        
        var msg = "User requests to update settings to new settings [\(newSettings.logDescription)]: "
        let res = dataSource.updateSettings(to: newSettingsCorrect)
        if res { msg += "Success" } else { msg += "Can not update settings" }
        Logger.shared.log(lvl: .DEBUG, msg: msg)
        return res
    }
    
    deinit {
        Logger.shared.log(lvl: .WARNING, msg: "SettingsController deinited")
    }
}
