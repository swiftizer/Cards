//
//  XCTest+Allure.swift
//  UnitTests
//
//  Created by ser.nikolaev on 09.10.2023.
//

import XCTest

extension XCTest {
    func feature(_ values: String...) {
        label(name: "feature", values: values)
    }

    func step(_ name: String, step: () -> Void) {
        XCTContext.runActivity(named: name) { _ in
            step()
        }
    }

    private func label(name: String, values: [String]) {
        for value in values {
            XCTContext.runActivity(named: "allure.label." + name + ":" + value, block: { _ in })
        }
    }
}
