//
//  BaseEndpointHandler.swift
//  API V1
//
//  Created by ser.nikolaev on 20.10.2023.
//

import Swifter

class BaseEndpointHandler {
    let server: HttpServer
    let path: String
    var CORSAllowHeaders: [String: String] = {
        var headers = [String: String]()
        headers["Access-Control-Allow-Origin"] = "*"
        headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        headers["Access-Control-Allow-Headers"] = "Content-Type"
        headers["Content-Type"] = "application/json"
        return headers
    }()
    lazy var successHeaders = {
        self.CORSAllowHeaders["Content-Type"] = "application/json"
        return self.CORSAllowHeaders
    }()
    lazy var failureHeaders = {
        self.CORSAllowHeaders["Content-Type"] = "text/plain"
        return self.CORSAllowHeaders
    }()

    init(server: HttpServer, path: String) {
        self.server = server
        self.path = path
    }
}
