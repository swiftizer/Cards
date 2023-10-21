//
//  APIV1Assembly.swift
//  API V1
//
//  Created by ser.nikolaev on 07.10.2023.
//

import Swifter
import Core
import Services

public final class APIV1Assembly {
    private let server = HttpServer()
    private var settingsEndpoint: SettingsEndpointHandler?
    private var cardSetsEndpoint: CardSetsEndpointHandler?
    private var cardsEndpoint: CardsEndpointHandler?

    public init(port: UInt16) {
        do {
            try server.start(port)
        } catch {
            print("Server start error: \(error)")
        }
    }

    public func assemble() -> Self {
        settingsEndpoint = SettingsEndpointHandler(server: server, settingsController: ModelProvider.shared.settingsController)
        cardSetsEndpoint = CardSetsEndpointHandler(server: server, cardSetController: ModelProvider.shared.cardSetController)
        cardsEndpoint = CardsEndpointHandler(server: server, cardSetController: ModelProvider.shared.cardSetController, cardController: ModelProvider.shared.cardController)
        return self
    }
}
