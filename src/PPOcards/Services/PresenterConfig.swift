//
//  PresenterConfig.swift
//  Services
//
//  Created by ser.nikolaev on 08.10.2023.
//

import Foundation
import Core

public struct PresenterConfig {
    public let cardController: CardControllerDescription?
    public let cardSetController: CardSetControllerDescription?
    public let cardSetID: UUID?

    public init(cardController: CardControllerDescription?, cardSetController: CardSetControllerDescription?, cardSetID: UUID?) {
        self.cardController = cardController
        self.cardSetController = cardSetController
        self.cardSetID = cardSetID
    }
}
