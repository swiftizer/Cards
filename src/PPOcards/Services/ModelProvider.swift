//
//  DBProvider.swift
//  PPOcards
//
//  Created by ser.nikolaev on 14.05.2023.
//

import Core
import DBCoreData
import DBRealm
import DBPostgres

public enum DBType {
    case CoreData
    case Realm
    case Postgres
}

public final class ModelProvider {

    public static var shared = ModelProvider()

    private init() {}
    
    public var settingsController: SettingsController!
    public var cardSetController: CardSetController!
    public var cardController: CardController!
    
    public func setupDB(type: DBType) {
        switch type {
        case .CoreData:
            settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
            cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)
            cardController = CardController(dataSource: CoreDataCardRepository(), cardSetController: cardSetController)
        case .Realm:
            settingsController = SettingsController(dataSource: RealmSettingsRepository())
            cardSetController = CardSetController(dataSource: RealmCardSetRepository(), settingsController: settingsController)
            cardController = CardController(dataSource: RealmCardRepository(), cardSetController: cardSetController)
        case .Postgres:
            settingsController = SettingsController(dataSource: PostgresSettingsRepository())
            cardSetController = CardSetController(dataSource: PostgresCardSetRepository(), settingsController: settingsController)
            cardController = CardController(dataSource: PostgresCardRepository(), cardSetController: cardSetController)
        }
    }
}
