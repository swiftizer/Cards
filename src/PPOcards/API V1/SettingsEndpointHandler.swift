//
//  SettingsEndpointHandler.swift
//  API V1
//
//  Created by ser.nikolaev on 08.10.2023.
//

import Foundation
import Swifter
import Core

final class SettingsEndpointHandler: BaseEndpointHandler {
    
    private let settingsController: SettingsControllerDescription

    init(server: HttpServer, settingsController: SettingsControllerDescription) {
        self.settingsController = settingsController
        super.init(server: server, path: "/settings")
        registerHandlers()
    }

    private func registerHandlers() {
        server[path] = { _ in
            return .raw(200, "OK", self.successHeaders, { _ in })
        }

        server.GET[path] = { [weak self] request in
            let settings = self?.settingsController.getSettings()
            if let jsonData = try? JSONEncoder().encode(settings) {
                return .raw(200, "OK", self?.successHeaders, { try? $0.write(jsonData) })
            }
            return .raw(404, "Not Found", self?.failureHeaders, .none)
        }

        server.PATCH[path] = { request in
            if let data = try? JSONDecoder().decode(Settings.self, from: Data(request.body)) {
                if self.settingsController.updateSettings(to: data) {
                    let updatedSettings = self.settingsController.getSettings()
                    if let jsonData = try? JSONEncoder().encode(updatedSettings) {
                        return .raw(200, "OK", self.successHeaders, { try? $0.write(jsonData) })
                    }
                    return .raw(404, "Not Found", self.failureHeaders, .none)
                }
            }
            return .raw(400, "Bad request", self.failureHeaders, { try? $0.write(Data("Incorrect request body".utf8)) })
        }
    }
}
