//
//  SettingsEndpointHandler.swift
//  API V1
//
//  Created by ser.nikolaev on 08.10.2023.
//

import Foundation
import Swifter
import Core

final class SettingsEndpointHandler {
    private let server: HttpServer
    private let path = "/settings"
    private let settingsController: SettingsControllerDescription
    private var CORSAllowHeaders: [String: String] = {
        var headers = [String: String]()
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
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

    init(server: HttpServer, settingsController: SettingsControllerDescription) {
        self.server = server
        self.settingsController = settingsController
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
