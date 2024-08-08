//
//  DataBuilders.swift
//  UnitTests
//
//  Created by ser.nikolaev on 22.10.2023.
//

import Core

struct CardFabric {
    static func getCard(withSimpleID id: Int) -> Card {
        return Card(id: setUUID(param: id), setID: setUUID(param: 5), isLearned: false)
    }

    static func getCard(withCustomID id: UUID) -> Card {
        return Card(id: id, setID: setUUID(param: 5), isLearned: false)
    }

    static func getUpdatedCard(withSimpleID id: Int) -> Card {
        return Card(id: setUUID(param: id), setID: setUUID(param: 5), isLearned: true)
    }

    static func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }
}

struct CardSetFabric {
    static func getCardSet(withSimpleID id: Int) -> CardSet {
        return CardSet(id: setUUID(param: id), title: "test_GetCardSet", allCardsCount: 0, learnedCardsCount: 0, color: 0xFF0000)
    }

    static func getCard(withSimpleID id: Int) -> Card {
        return Card(id: setUUID(param: id), setID: setUUID(param: 5), isLearned: false)
    }

    static func getLearnedCard(withSimpleID id: Int) -> Card {
        return Card(id: setUUID(param: id), setID: setUUID(param: 5), isLearned: true)
    }

    static func getNotLearnedCard(withSimpleID id: Int) -> Card {
        return Card(id: setUUID(param: id), setID: setUUID(param: 5), isLearned: false)
    }

    static func getUpdatedCardSet(withSimpleID id: Int) -> CardSet {
        return CardSet(id: setUUID(param: id), title: "test_GetCardSet", allCardsCount: 5, learnedCardsCount: 3, color: 0xFF0A00)
    }

    static func setUUID(param: Int) -> UUID {
        return UUID(uuidString: "00000000-0000-0000-0000-00000000000" + String(param))!
    }
}

struct SettingsFabric {
    static func getSettings() -> Settings {
        return Settings(isMixed: false, mixingInPower: 0)
    }

    static func getUpdatedSettingsStandart() -> Settings {
        return Settings(isMixed: true, mixingInPower: 18)
    }

    static func getUpdatedSettingsLess() -> Settings {
        return Settings(isMixed: true, mixingInPower: -10)
    }

    static func getUpdatedSettingsMin() -> Settings {
        return Settings(isMixed: true, mixingInPower: 0)
    }

    static func getUpdatedSettingsGreater() -> Settings {
        return Settings(isMixed: true, mixingInPower: 225)
    }

    static func getUpdatedSettingsMax() -> Settings {
        return Settings(isMixed: true, mixingInPower: 100)
    }
}
