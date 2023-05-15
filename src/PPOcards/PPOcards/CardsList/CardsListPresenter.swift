//
//  CardsListPresenter.swift
//  PPOcards
//
//  Created by ser.nikolaev on 01.05.2023.
//

import Foundation
import Core

final class CardsListPresenter {
    private let config: PresenterConfig
    private var cardController: CardControllerDescription?
    private var cardSetController: CardSetControllerDescription?
    private let cardSetID: UUID
    
    var dataEditedNotify: (() -> ())?
    
    init(config: PresenterConfig) {
        self.config = config
        cardSetController = config.cardSetController
        cardController = config.cardController
        cardSetID = config.cardSetID ?? UUID()
    }
    
    private var getCardIDs: [UUID] {
        cardSetController?.getAllCardIDsFromSet(from: cardSetID) ?? []
    }
    
    private lazy var cardIDs = getCardIDs
    
    private lazy var editingCompletion: (Card?) -> () = { newCard in
        if let newCard = newCard {
            var card = newCard
            if self.cardController?.getCard(ID: newCard.id) == nil {
                card = (self.cardController?.createCard(for: self.cardSetID))!
                card.questionText = newCard.questionText
                card.answerText = newCard.answerText
                card.answerImageURL = newCard.answerImageURL
                card.questionImageURL = newCard.questionImageURL
                card.isLearned = newCard.isLearned
            }
            let _ = self.cardController?.updateCard(oldID: card.id, new: card)
            self.cardIDs = self.getCardIDs
            self.dataEditedNotify?()
        }
    }
    
    func prepareEditCardVCForAdd() -> EditCardVC {
        EditCardVC(card: Card(id: UUID(), setID: cardSetID, isLearned: false), completion: editingCompletion)
    }
    
    func numberOfTVRows() -> Int {
        cardIDs.count
    }
    
    func cardForTVRow(index: Int) -> Card? {
        cardController?.getCard(ID: cardIDs[index])
    }
    
    func prepareEditCardVCForEdit(index: Int) -> EditCardVC {
        EditCardVC(card: cardController?.getCard(ID: cardIDs[index]), completion: editingCompletion)
    }
    
    func prepareCardSetsChoosingVC(index: Int) -> CardSetsChoosingVC {
        let vc = CardSetsChoosingVC(config: config)
        vc.completion = { choosedCSID in
            let _ = self.cardController?.shareCardToSet(cardID: self.cardIDs[index], newSetID: choosedCSID)
            self.dataEditedNotify?()
        }
        return vc
    }
    
    func deleteCard(index: Int) {
        let _ = cardController?.deleteCard(ID: cardIDs[index])
        cardIDs = getCardIDs
    }
    
    func rateForCard(index: Int) -> String {
        guard let progress = cardController?.getCardProgress(cardSetID: cardSetID, cardID: cardIDs[index]) else { return " (-)" }
        let res = progress.allAttemptsCount == 0 ? " (?)" : " (\(Int(Double(progress.successCount) / Double(progress.allAttemptsCount) * 100.0))%)"
        return res
    }
}
