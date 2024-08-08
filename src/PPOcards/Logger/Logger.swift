//
//  Logger.swift
//  Core
//
//  Created by ser.nikolaev on 22.04.2023.
//

import Foundation

public enum LogLevel: String, CaseIterable {
    case ERROR
    case WARNING
    case INFO
    case DEBUG
    case VERBOSE
}

public final class RunMode {
    public static func isRunningTests() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("-XCTest")
    }
}

public final class Logger {
    public static let shared: Logger = Logger()
    private var minLogLvl: LogLevel = .VERBOSE
    
    private let priorities: [LogLevel:Int] = {
        var dict = [LogLevel:Int]()
        for _case in LogLevel.allCases {
            switch _case {
            case .ERROR:
                dict[.ERROR] = 0
            case .WARNING:
                dict[.WARNING] = 1
            case .INFO:
                dict[.INFO] = 2
            case .DEBUG:
                dict[.DEBUG] = 3
            case .VERBOSE:
                dict[.VERBOSE] = 4
            }
        }
        return dict
    }()
    
    private init() {
        setupLoggingFile()
    }
    
    private var logFileURL: URL?
        
    private func setupLoggingFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        logFileURL = documentsDirectory.appendingPathComponent("log.log")
        
        if FileManager.default.fileExists(atPath: logFileURL!.path) {
            try? FileManager.default.removeItem(at: logFileURL!)
        }
        
        FileManager.default.createFile(atPath: logFileURL!.path, contents: nil, attributes: nil)
    }

    
    public func log(lvl: LogLevel, msg: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        guard let logFileURL = logFileURL, priorities[lvl] ?? 5 <= priorities[minLogLvl] ?? 5 else { return }
        
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        
        let logMessage = "[\(timestamp)] \(file):\(function) (line \(line))\n\(lvl.rawValue): \(msg)\n"
        
        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            fileHandle.seekToEndOfFile()
            if let data = logMessage.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
    }

    
    public func setLoggingLevel(newLvl: LogLevel) {
        minLogLvl = newLvl
    }
}
