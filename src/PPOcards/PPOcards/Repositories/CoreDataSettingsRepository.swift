//
//  CoreDataSettingsRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData


class CoreDataSettingsRepository: SettingsRepositoryDescription {

    init() {
        if !UserDefaults.exists(key: "SettingsIsMixed") || !UserDefaults.exists(key: "SettingsMixingInPower") {
            let _ = createSettings()
        }
    }

    private func createSettings() -> Bool {
        UserDefaults.standard.set(false, forKey: "SettingsIsMixed")
        UserDefaults.standard.set(0, forKey: "SettingsMixingInPower")
        return true
    }

    func getSettings() -> Settings {
        Settings(isMixed: UserDefaults.standard.bool(forKey: "SettingsIsMixed"), mixingInPower: UserDefaults.standard.integer(forKey: "SettingsMixingInPower"))
    }

    func updateSettings(to newSettings: Settings) -> Bool {
        UserDefaults.standard.set(newSettings.isMixed, forKey: "SettingsIsMixed")
        UserDefaults.standard.set(newSettings.mixingInPower, forKey: "SettingsMixingInPower")
        return true
    }


}
