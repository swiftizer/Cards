//
//  Benchmark.swift
//  Benchmark
//
//  Created by ser.nikolaev on 10.12.2023.
//

import XCTBeton
import Services
import DBCoreData
@testable import Core

struct Measurments: Codable {
    let db: String
    let measures: Measurment
}

struct Measurment: Codable {
    let clock: [Double]
    let cpu: [Double]
    let memory: [Double]
}

final class Benchmark: XCTestCase {
    static var measurments: [Measurments] {
        get {
            if let savedMeasurments = UserDefaults.standard.object(forKey: "measurments") as? Data {
                let decoder = JSONDecoder()
                if let loadedMeasurments = try? decoder.decode([Measurments].self, from: savedMeasurments) {
                    return loadedMeasurments
                }
            }
            return [Measurments]()
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: "measurments")
            }
        }
    }

    override func setUp() {

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        if Self.measurments.count == 3 {
            dumpToFile(name: "BenchmarkResults.json")
            Self.measurments = []
        }
    }

    func test_30PerformanceCoreData() {
        ModelProvider.shared.setupDB(type: .CoreData)
        refillDB()
        let cardSetController = ModelProvider.shared.cardSetController!

        let clockMetric = XCTClockMetric()
        let cpuMetric: XCTMetric = XCTCPUMetric()
        let memoryMetric = XCTMemoryMetric()

        let options = XCTMeasureOptions()
        options.iterationCount = 100

        measure(metrics: [clockMetric, cpuMetric, memoryMetric], options: options) {
            let _ = cardSetController.getAllCardSets()
        }

        let clock = clockMetric.measurements.map(\.doubleValue)
        let cpu = cpuMetric.measurements.map(\.doubleValue).filter { $0 > 793104 }.constraintTo(length: 100)
        let memory = memoryMetric.measurements.map(\.doubleValue).filter { $0 > 100000 }.constraintTo(length: 100)
        Self.measurments.append(.init(db: "CoreData", measures: .init(clock: clock, cpu: cpu, memory: memory)))
    }

    func test_21PerformanceRealm() {
        ModelProvider.shared.setupDB(type: .Realm)
        refillDB()
        let cardSetController = ModelProvider.shared.cardSetController!

        let clockMetric = XCTClockMetric()
        let cpuMetric: XCTMetric = XCTCPUMetric()
        let memoryMetric = XCTMemoryMetric()

        let options = XCTMeasureOptions()
        options.iterationCount = 100

        measure(metrics: [clockMetric, cpuMetric, memoryMetric], options: options) {
            let _ = cardSetController.getAllCardSets()
        }

        let clock = clockMetric.measurements.map(\.doubleValue)
        let cpu = cpuMetric.measurements.map(\.doubleValue).filter { $0 > 793104 }.constraintTo(length: 100)
        let memory = memoryMetric.measurements.map(\.doubleValue).filter { $0 > 100000 }.constraintTo(length: 100)
        Self.measurments.append(.init(db: "Realm", measures: .init(clock: clock, cpu: cpu, memory: memory)))
    }

    func test_12PerformancePostgres() {
        ModelProvider.shared.setupDB(type: .Postgres)
        refillDB()
        let cardSetController = ModelProvider.shared.cardSetController!

        let clockMetric = XCTClockMetric()
        let cpuMetric: XCTMetric = XCTCPUMetric()
        let memoryMetric = XCTMemoryMetric()

        let options = XCTMeasureOptions()
        options.iterationCount = 100

        measure(metrics: [clockMetric, cpuMetric, memoryMetric], options: options) {
            let _ = cardSetController.getAllCardSets()
        }

        let clock = clockMetric.measurements.map(\.doubleValue)
        let cpu = cpuMetric.measurements.map(\.doubleValue).filter { $0 > 793104 }.constraintTo(length: 100)
        let memory = memoryMetric.measurements.map(\.doubleValue).filter { $0 > 900000 }.constraintTo(length: 100)
        Self.measurments.append(.init(db: "Postgres", measures: .init(clock: clock, cpu: cpu, memory: memory)))
    }

    private func dumpToFile(name: String) {
        let dir = try? FileManager.default.url(for: .desktopDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(Self.measurments) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                do {
                    if let fileURL = dir?.appendingPathComponent("testing-and-debugging/src/PPOcards/Benchmark/\(name)") {
                        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                    }
                } catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
            }
        }
    }

    private func refillDB() {
        let cardSetController = ModelProvider.shared.cardSetController!
        cardSetController.deleteAllCardSets()
        for i in 0...100 {
            let _ = cardSetController.createCardSet(title: "test\(i)")
        }
    }
}

fileprivate extension Array {
    func constraintTo(length: Int) -> Array {
        if self.count <= length { return self }
        let step = self.count / length
        return stride(from: 0, to: self.count, by: step).map { self[$0] }
    }
}
