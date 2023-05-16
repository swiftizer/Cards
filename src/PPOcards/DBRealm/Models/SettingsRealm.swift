//
//  SettingsRealm.swift
//  DBRealm
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import RealmSwift

class SettingsRealm: Object {
    @Persisted var isMixed: Bool
    @Persisted var mixingInPower: Int?
    
    convenience init(isMixed: Bool, mixingInPower: Int? = nil) throws {
        self.init()

        self.isMixed = isMixed
        self.mixingInPower = mixingInPower
    }
}

extension SettingsRealm {
    func convertToSettings() -> Settings {
        return Settings(isMixed: self.isMixed, mixingInPower: self.mixingInPower)
    }
}

extension Settings {
    func convertToSettingsRealm() -> SettingsRealm {
        return try! SettingsRealm(isMixed: self.isMixed, mixingInPower: self.mixingInPower)
    }
}
