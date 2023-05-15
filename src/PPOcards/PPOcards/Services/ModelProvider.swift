//
//  DBProvider.swift
//  PPOcards
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import DBCoreData
import DBRealm

enum DBType {
    case CoreData
    case Realm
}

final class ModelProvider {
    
    static var shared = ModelProvider()
    
    private init() {}
    
    var settingsController: SettingsController!
    var cardSetController: CardSetController!
    var cardController: CardController!
    
    func setupDB(type: DBType) {
        switch type {
        case .CoreData:
            settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
            cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)
            cardController = CardController(dataSource: CoreDataCardRepository(), cardSetController: cardSetController)
        case .Realm:
            settingsController = SettingsController(dataSource: RealmSettingsRepository())
            cardSetController = CardSetController(dataSource: RealmCardSetRepository(), settingsController: settingsController)
            cardController = CardController(dataSource: RealmCardRepository(), cardSetController: cardSetController)
        }
    }
}
