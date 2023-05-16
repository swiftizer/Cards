//
//  CardsLearningPresenter.swift
//  PPOcards
//
//  Created by ser.nikolaev on 01.05.2023.
//

import Foundation
import Core

enum CardSide {
    case question
    case answer
}

final class CardsLearningPresenter {
    private let config: PresenterConfig
    private var cardController: CardControllerDescription?
    private var cardSetController: CardSetControllerDescription?
    private let cardSetID: UUID
    
    var nextCardNotify: (() -> ())?
    
    init(config: PresenterConfig) {
        self.config = config
        cardSetController = config.cardSetController
        cardController = config.cardController
        cardSetID = config.cardSetID ?? UUID()
    }
    
    private var getNotLearnedCardIDs: [UUID] {
        cardSetController?.getNotLearnedCardIDsFromSet(from: cardSetID) ?? []
    }
    
    private lazy var notLearnedCardIDs: [UUID] = getNotLearnedCardIDs
    
    private var allLearnedCardIDs: [UUID] {
        cardSetController?.getAllCardIDsFromSet(from: cardSetID) ?? []
    }
    
    private var allLearnedCards: [Card] {
        var res = [Card]()
        for ID in allLearnedCardIDs {
            if let card = cardController?.getCard(ID: ID) {
                res.append(card)
            }
        }
        return res
    }
    
    var curCardInd = 0 {
        didSet {
            nextCardNotify?()
        }
    }
    
    var curNotlearnedCard: Card? {
        if curCardInd < notLearnedCardIDs.count {
            return cardController?.getCard(ID: notLearnedCardIDs[curCardInd])
        }
        return nil
    }
    
    private func nextCard() {
        curCardInd += 1
    }
    
    func counterLabelText() -> String {
        "\(min(curCardInd+1, notLearnedCardIDs.count))/\(notLearnedCardIDs.count)"
    }
    
    func reload() {
        let oldCard = curNotlearnedCard
        notLearnedCardIDs = getNotLearnedCardIDs
        if let ind = notLearnedCardIDs.firstIndex(where: { $0 == oldCard?.id }) {
            curCardInd = ind
        }
    }
    
    func prepareCardLayout(side: CardSide) -> (String?, URL?) {
        switch side {
        case .question:
            return (curNotlearnedCard?.questionText, curNotlearnedCard?.questionImageURL)
        case .answer:
            return (curNotlearnedCard?.answerText, curNotlearnedCard?.answerImageURL)
        }
    }
    
    func accept() {
        guard let card = curNotlearnedCard else { return }
        let _ = cardController?.markAsLearned(cardID: card.id)
        
        nextCard()
    }
    
    func decline() {
        guard let card = curNotlearnedCard else { return }
        let _ = cardController?.markAsNotLearned(cardID: card.id)
        
        nextCard()
    }
    
    func restart() {
        notLearnedCardIDs = getNotLearnedCardIDs
        if notLearnedCardIDs.count == 0 {
            for ID in cardSetController?.getAllCardIDsFromSet(from: cardSetID) ?? [] {
                if let card = cardController?.getCard(ID: ID) {
                    var updCard = card
                    updCard.isLearned = false
                    let _ = cardController?.updateCard(oldID: card.id, new: updCard)
                }
            }
            notLearnedCardIDs = getNotLearnedCardIDs
        }
        curCardInd = 0
    }
    
    func progressLabelText() -> String {
        guard let progress = cardController?.getCardProgress(cardSetID: cardSetID, cardID: curNotlearnedCard?.id ?? UUID()) else { return " " }
        let res = progress.allAttemptsCount == 0 ? "-" : "\(Int(Double(progress.successCount) / Double(progress.allAttemptsCount) * 100.0)) %"
        return "Rate: " + res
    }
    
    func prepareCardsListVC(rootVC: CardsLearningVC) -> CardsListVC {
        CardsListVC(rootVC: rootVC, config: config)
    }
    
    func prepareEditCardVC() -> EditCardVC {
        EditCardVC(card: curNotlearnedCard, completion: nil, readOnlyFlag: true)
    }
}
