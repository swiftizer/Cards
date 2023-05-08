//
//  CardSetsPresenter.swift
//  PPOcards
//
//  Created by ser.nikolaev on 30.04.2023.
//

import Foundation
import Core
import DBCoreData

final class CardSetsPresenter {
    private let settingsController = SettingsController(dataSource: CoreDataSettingsRepository())
    private lazy var cardSetController = CardSetController(dataSource: CoreDataCardSetRepository(), settingsController: settingsController)
    private lazy var cardController = CardController(dataSource: CoreDataCardRepository(), cardSetController: cardSetController)
    
    init() {
        cardSetController.cardController = cardController
    }
    
    private var getCardSets: [CardSet] {
        self.cardSetController.getAllCardSets()
    }
    private lazy var cardSets = getCardSets
    
    func fillDB() {
        cardController.deleteAllCards()
        cardSetController.deleteAllCardSets()
        let setID1 = cardSetController.createCardSet(title: "test1").id
        let setID2 = cardSetController.createCardSet(title: "test2").id
        let setID3 = cardSetController.createCardSet(title: "test3").id
        
        var c11 = cardController.createCard(for: setID1)
        c11.answerText = "Answer11"
        c11.questionText = "Question11"
        c11.isLearned = false
        let _ = cardController.updateCard(oldID: c11.id, new: c11, isRestart: true)
        var c12 = cardController.createCard(for: setID1)
        c12.answerText = "Answer12"
        c12.questionText = "Question12"
        c12.isLearned = false
        let _ = cardController.updateCard(oldID: c12.id, new: c12, isRestart: true)
        var c13 = cardController.createCard(for: setID1)
        c13.answerText = "Answer13"
        c13.questionText = "Question13"
        c13.isLearned = false
        let _ = cardController.updateCard(oldID: c13.id, new: c13, isRestart: true)
        
        var c21 = cardController.createCard(for: setID2)
        c21.answerText = "Answer21"
        c21.questionText = "Question21"
        c21.isLearned = false
        let _ = cardController.updateCard(oldID: c21.id, new: c21, isRestart: true)
        var c22 = cardController.createCard(for: setID2)
        c22.answerText = "Answer22"
        c22.questionText = "Question22"
        c22.isLearned = false
        let _ = cardController.updateCard(oldID: c22.id, new: c22, isRestart: true)
        
        var c31 = cardController.createCard(for: setID3)
        c31.answerText = "Answer31"
        c31.questionText = "Question31"
        c31.answerImageURL = MyFileManager.shared.putImageToFS(with: ImagesProvider.shared.images["t"]!)
        c31.isLearned = false
        let _ = cardController.updateCard(oldID: c31.id, new: c31, isRestart: true)
        var c32 = cardController.createCard(for: setID3)
        c32.answerText = "Answer32"
        c32.questionText = "Question32"
        c32.answerImageURL = MyFileManager.shared.putImageToFS(with: ImagesProvider.shared.images["t1"]!)
        c32.isLearned = false
        let _ = cardController.updateCard(oldID: c32.id, new: c32, isRestart: true)
        var c33 = cardController.createCard(for: setID3)
        c33.answerText = "Answer33"
        c33.questionText = "Question33"
        c33.isLearned = false
        let _ = cardController.updateCard(oldID: c33.id, new: c33, isRestart: true)
        var c34 = cardController.createCard(for: setID3)
        c34.answerText = "Answer34"
        c34.questionText = "Question34"
        c34.answerImageURL = MyFileManager.shared.putImageToFS(with: ImagesProvider.shared.images["t2"]!)
        c34.isLearned = false
        let _ = cardController.updateCard(oldID: c34.id, new: c34, isRestart: true)
        
        let _ = settingsController.updateSettings(to: Settings(isMixed: false))
        cardSets = getCardSets
    }
    
    func viewWillAppear() {
        cardSets = getCardSets
    }
    
    func addCardSetAction(name: String) {
        let _ = cardSetController.createCardSet(title: name)
        cardSets = getCardSets
    }
    
    func setupSettingsVCToPresent(with action: @escaping () -> ()) -> SettingsVC {
        SettingsVC(presenter: SettingsPresenter(settingsController: settingsController), refillAction: action)
    }
    
    func numberOfTVRows() -> Int {
        cardSets.count
    }
    
    func cardSetForTVRow(index: Int) -> CardSet {
        cardSets[index]
    }
    
    func setupCardsLearningVCToPush(index: Int) -> CardsLearningVC {
        CardsLearningVC(config: PresenterConfig(cardController: cardController, cardSetController: cardSetController, cardSetID: cardSets[index].id))
    }
    
    func deleteCardSetFromTV(index: Int) {
        let _ = self.cardSetController.deleteCardSet(ID: cardSets[index].id)
        cardSets = getCardSets
    }
    
    func updateCardSetFromTV(index: Int, name: String) {
        var old = cardSets[index]
        old.title = name
        let _ = cardSetController.updateCardSet(oldID: old.id, new: old)
        cardSets = getCardSets
    }
    
    func getCardSetTitle(index: Int) -> String {
        cardSets[index].title
    }
}
