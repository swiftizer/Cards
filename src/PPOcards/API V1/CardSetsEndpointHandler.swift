//
//  CardSetsEndpointHandler.swift
//  API V1
//
//  Created by ser.nikolaev on 17.10.2023.
//

import Swifter
import Core

final class CardSetsEndpointHandler: BaseEndpointHandler {

    private let cardSetController: CardSetControllerDescription

    init(server: HttpServer, cardSetController: CardSetControllerDescription) {
        self.cardSetController = cardSetController
        super.init(server: server, path: "/card_sets")
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
                  let limit = Int(limitStr), limit >= 0
            else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Missing limit parameter".utf8)) })
            }

            if let offset = Int(request.queryParams.first(where: { $0.0 == "offset" })?.1 ?? "") {
                if offset < 0 {
                    return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Missing limit parameter".utf8)) })
                }
            }
            let offset = Int(request.queryParams.first(where: { $0.0 == "offset" })?.1 ?? "")
            let allCardSets = self?.cardSetController.getAllCardSets().paginate(limit: limit, offset: offset)
            do {
                let jsonData = try JSONEncoder().encode(allCardSets)
                return .raw(200, "OK", self?.successHeaders, { try? $0.write(jsonData) })
            } catch {
                return .raw(404, "Not Found", self?.failureHeaders, .none)
            }
        }

        server.POST[path] = { request in
            if let data = try? JSONDecoder().decode(CardSet.self, from: Data(request.body)) {
                var createdCardSet = self.cardSetController.createCardSet(title: data.title)
                createdCardSet.allCardsCount = data.learnedCardsCount
                createdCardSet.learnedCardsCount = data.learnedCardsCount
                createdCardSet.color = data.color
                if self.cardSetController.updateCardSet(oldID: createdCardSet.id, new: createdCardSet),
                {self.cardSetController.updateCardSetProgress(cardSetID: createdCardSet.id); return true}(),
                let addedCardSet = self.cardSetController.getCardSet(ID: createdCardSet.id),
                    let jsonData = try? JSONEncoder().encode(addedCardSet) {
                        return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
                    }
                return .raw(400, "Bad request", self.failureHeaders, .none)
            }
            return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Incorrect request body".utf8)) })
        }

        server.GET[path + "/:id"] = { [weak self] request in
            guard let idStr = request.params.first(where: { $0.0 == ":id" })?.1,
                  let id = UUID(uuidString: idStr) else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Incorrect id".utf8)) })
            }

            if let cardSet = self?.cardSetController.getCardSet(ID: id),
               let jsonData = try? JSONEncoder().encode(cardSet) {
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

            if let data = try? JSONDecoder().decode(CardSet.self, from: Data(request.body)) {
                if let _ = self.cardSetController.getCardSet(ID: id),
                   self.cardSetController.updateCardSet(oldID: id, new: data),
                   {self.cardSetController.updateCardSetProgress(cardSetID: data.id); return true}(),
                   let updatedCardSet = self.cardSetController.getCardSet(ID: id),
                   let jsonData = try? JSONEncoder().encode(updatedCardSet) {
                        return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
                    }
                return .raw(400, "Bad request", self.failureHeaders, .none)
            }
            return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Incorrect request body".utf8)) })
        }

        server.DELETE[path + "/:id"] = { [weak self] request in
            guard let idStr = request.params.first(where: { $0.0 == ":id" })?.1,
                  let id = UUID(uuidString: idStr),
                  let self = self else {
                return .raw(400, "Bad request", self?.failureHeaders, { try? $0.write(Data("Incorrect id".utf8)) })
            }

            if self.cardSetController.deleteCardSet(ID: id) {
                return .raw(200, "OK", self.successHeaders, { try? $0.write(Data()) })
            }
            return .raw(400, "Bad request", self.failureHeaders, .none)
        }
    }
}
