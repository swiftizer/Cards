//
//  RealmSettingsRepository.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import RealmSwift
import Core


public class RealmSettingsRepository: SettingsRepositoryDescription {
    
    let realm = try! Realm()
    
    public init() {
        if realm.objects(SettingsRealm.self).count == 0 {
            let _ = createSettings()
        }
    }
    
    private func createSettings() -> Bool {
        do {
            try realm.write {
                realm.add(try! SettingsRealm(isMixed: false, mixingInPower: 0))
            }
        } catch {
            return false
        }
        
        return true
    }
    
    public func getSettings() -> Core.Settings {
        let settings = realm.objects(SettingsRealm.self).first

        return settings!.convertToSettings()
    }
    
    public func updateSettings(to newSettings: Core.Settings) -> Bool {
        var settings = realm.objects(SettingsRealm.self).first
        
        let realmNewSettings = newSettings.convertToSettingsRealm()
        
        do {
            try realm.write {
                settings?.isMixed = realmNewSettings.isMixed
                settings?.mixingInPower = realmNewSettings.mixingInPower
            }
        } catch {
            return false
        }
        
        return true
    }
    
    
}
