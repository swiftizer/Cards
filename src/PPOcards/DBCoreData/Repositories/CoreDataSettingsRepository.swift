//
//  CoreDataSettingsRepository.swift
//  PPOcards
//
//  Created by Сергей Николаев on 09.04.2023.
//

import CoreData
import Core


public class CoreDataSettingsRepository: SettingsRepositoryDescription {

    private let coreDataManager: CoreDataManagerDescription!

    public init() {
        coreDataManager = CoreDataManager.shared
        guard let _ = coreDataManager.fetch(request: SettingsMO.fetchRequest()).first else {
            let _ = createSettings()
            return
        }
    }

    public init(customDataManager: CoreDataManagerDescription) {
        coreDataManager = customDataManager
        guard let _ = coreDataManager.fetch(request: SettingsMO.fetchRequest()).first else {
            let _ = createSettings()
            return
        }
    }

    private func createSettings() -> Bool {
        coreDataManager.create(entityName: "SettingsMO") { settingsMO in
            guard let settingsMO = settingsMO as? SettingsMO else { return }

            settingsMO.isMixed = false
            settingsMO.mixingInPower = 0
        }
        return true
    }

    public func getSettings() -> Settings {
        let fetchRequest: NSFetchRequest<SettingsMO> = SettingsMO.fetchRequest()

        guard let settingsMO = coreDataManager.fetch(request: fetchRequest).first else {
            let _ = createSettings()
            return getSettings()
        }

        let settings = Settings(isMixed: settingsMO.isMixed, mixingInPower: Int(settingsMO.mixingInPower))

        return settings
    }

    public func updateSettings(to newSettings: Settings) -> Bool {
        let fetchRequest: NSFetchRequest<SettingsMO> = SettingsMO.fetchRequest()

        coreDataManager.update(request: fetchRequest) { settingsMO in
            guard let settingsMO = settingsMO as? SettingsMO else { return }

            settingsMO.isMixed = newSettings.isMixed
            settingsMO.mixingInPower = Int32(newSettings.mixingInPower ?? 0)
        }

        return true
    }


}
