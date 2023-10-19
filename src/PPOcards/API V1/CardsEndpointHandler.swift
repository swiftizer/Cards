//
//  CardsEndpointHandler.swift
//  API V1
//
//  Created by ser.nikolaev on 18.10.2023.
//

import Swifter
import Core

final class CardsEndpointHandler {
    private let server: HttpServer
    private let path = "/cards"
    private let cardSetController: CardSetControllerDescription
    private let cardController: CardControllerDescription
    private var CORSAllowHeaders: [String: String] = {
        var headers = [String: String]()
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = "GET,POST,DELETE,PUT,PATCH,OPTIONS"
        headers["Access-Control-Allow-Headers"] = "Content-Type"
        headers["Content-Type"] = "application/json"
        return headers
    }()
    private lazy var successHeaders = {
        self.CORSAllowHeaders["Content-Type"] = "application/json"
        return self.CORSAllowHeaders
    }()
    private lazy var failureHeaders = {
        self.CORSAllowHeaders["Content-Type"] = "text/plain"
        return self.CORSAllowHeaders
    }()

    init(server: HttpServer, cardSetController: CardSetControllerDescription, cardController: CardControllerDescription) {
        self.server = server
        self.cardSetController = cardSetController
        self.cardController = cardController
        registerHandlers()
    }

    private func registerHandlers() {
        server[path] = { _ in
            return .raw(200, "OK", self.successHeaders, { _ in })
        }

        server[path + "/:id"] = { _ in
            return .raw(200, "OK", self.successHeaders, { _ in })
        }

        server.GET[path] = { [weak self] request in
            guard let limitStr = request.queryParams.first(where: { $0.0 == "limit" })?.1,
                  let limit = Int(limitStr),
                  let self = self, limit > 0
            else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Missing limit parameter".utf8)) })
            }
            if let offset = Int(request.queryParams.first(where: { $0.0 == "offset" })?.1 ?? "") {
                if offset < 0 {
                    return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Missing limit parameter".utf8)) })
                }
            }
            let offset = Int(request.queryParams.first(where: { $0.0 == "offset" })?.1 ?? "")
            let cardSetId = UUID(uuidString: (request.queryParams.first(where: { $0.0 == "card_set_id" })?.1 ?? ""))
            let isLearned = Bool(request.queryParams.first(where: { $0.0 == "is_learned" })?.1 ?? "")

            var allCardIds: [UUID]
            var allCards: [Card]
            if let cardSetId = cardSetId {
                if let isLearned = isLearned {
                    switch isLearned {
                    case true:
                        allCardIds = cardSetController.getLearnedCardIDsFromSet(from: cardSetId)
                    case false:
                        allCardIds = cardSetController.getNotLearnedCardIDsFromSet(from: cardSetId)
                    }
                } else {
                    allCardIds = cardSetController.getAllCardIDsFromSet(from: cardSetId)
                }
                allCards = allCardIds.compactMap { self.cardController.getCard(ID: $0) }
            } else {
                allCards = cardSetController.getAllCardSets()
                    .map(\.id)
                    .flatMap { self.cardSetController.getAllCardIDsFromSet(from: $0) }
                    .compactMap { self.cardController.getCard(ID: $0) }
                if let isLearned = isLearned {
                    allCards = allCards.filter { $0.isLearned == isLearned }
                }
            }

            do {
                let jsonData = try JSONEncoder().encode(allCards.paginate(limit: limit, offset: offset))
                return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
            } catch {
                return .raw(404, "Not Found", self.failureHeaders, .none)
            }
        }

        server.POST[path] = { request in
            if let data = try? JSONDecoder().decode(Card.self, from: Data(request.body)) {
                guard let csID = self.cardSetController.getCardSet(ID: data.setID ?? UUID()) else {
                    return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Non-existed card set".utf8)) })
                }
                var createdCard = self.cardController.createCard(for: data.setID ?? UUID())
                createdCard.questionText = data.questionText
                createdCard.questionImageURL = data.questionImageURL
                createdCard.answerText = data.answerText
                createdCard.answerImageURL = data.answerImageURL
                createdCard.isLearned = data.isLearned

                if self.cardController.updateCard(oldID: createdCard.id, new: createdCard),
                   let addedCard = self.cardController.getCard(ID: createdCard.id),
                   let jsonData = try? JSONEncoder().encode(addedCard) {
                    return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
                }
                return .raw(404, "Not Found", self.failureHeaders, .none)
            }
            return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Incorrect request body".utf8)) })
        }

        server.GET[path + "/:id"] = { [weak self] request in
            guard let idStr = request.params.first(where: { $0.0 == ":id" })?.1,
                  let id = UUID(uuidString: idStr) else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Incorrect id".utf8)) })
            }

            if let card = self?.cardController.getCard(ID: id),
               let jsonData = try? JSONEncoder().encode(card) {
                return .raw(200, "OK", self?.successHeaders, { try? $0.write(jsonData) })
            }
            return .raw(404, "Not Found", self?.failureHeaders, .none)
        }

        server.PUT[path + "/:id"] = { [weak self] request in
            guard let idStr = request.params.first(where: { $0.0 == ":id" })?.1,
                  let id = UUID(uuidString: idStr),
                  let self = self else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Incorrect id".utf8)) })
            }

            if let data = try? JSONDecoder().decode(Card.self, from: Data(request.body)) {
                if let card = self.cardController.getCard(ID: id),
                   self.cardController.updateCard(oldID: id, new: data),
                   let updatedCard = self.cardController.getCard(ID: id),
                   let jsonData = try? JSONEncoder().encode(updatedCard) {
                    return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
                }
                return .raw(404, "Not Found", self.failureHeaders, .none)
            }
            return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Incorrect request body".utf8)) })
        }

        server.DELETE[path + "/:id"] = { [weak self] request in
            guard let idStr = request.params.first(where: { $0.0 == ":id" })?.1,
                  let id = UUID(uuidString: idStr),
                  let self = self else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Incorrect id".utf8)) })
            }

            if self.cardController.deleteCard(ID: id) {
                return .raw(200, "OK", self.successHeaders, { try? $0.write(Data()) })
            }
            return .raw(404, "Not Found", self.failureHeaders, .none)
        }
    }
}
