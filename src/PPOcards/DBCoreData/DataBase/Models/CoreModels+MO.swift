//
//  Card+MO.swift
//  DBCoreData
//
//  Created by ser.nikolaev on 20.10.2023.
//

import Core

public extension Card {
    // передаем созданный МО, потому что он должен создаваться с контекстом, которого тут нет
    func toCoreData(createdCardMO: CardMO) -> CardMO {
        createdCardMO.id = self.id
        createdCardMO.setID = self.setID
        createdCardMO.questionText = self.questionText
        createdCardMO.answerText = self.answerText
        createdCardMO.isLearned = self.isLearned
        createdCardMO.questionImageURL = self.questionImageURL
        createdCardMO.answerImageURL = self.answerImageURL
        return createdCardMO
    }
}

public extension CardSet {
    func toCoreData(createdCardSetMO: CardSetMO) -> CardSetMO {
        createdCardSetMO.id = self.id
        createdCardSetMO.title = self.title
        createdCardSetMO.allCardsCount = Int32(self.allCardsCount)
        createdCardSetMO.learnedCardsCount = Int32(self.learnedCardsCount)
        createdCardSetMO.color = Int32(self.color)
        return createdCardSetMO
    }
}

public extension Settings {
    func toCoreData(settingsMO: SettingsMO) -> SettingsMO {
        settingsMO.isMixed = self.isMixed
        settingsMO.mixingInPower = Int32(self.mixingInPower ?? 0)
        return settingsMO
    }
}
