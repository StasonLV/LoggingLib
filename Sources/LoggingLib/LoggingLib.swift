// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog

public extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static var viewCycle: Logger {
        Logger(subsystem: subsystem, category: "ViewcycleLogging")
    }
    
    static var statistics: Logger {
        Logger(subsystem: subsystem, category: "StatisticsLogging")
    }
    
    static var ui: Logger {
        Logger(subsystem: subsystem, category: "InterfaceLogging")
    }
    
    static var network: Logger {
        Logger(subsystem: subsystem, category: "NetworkLogging")
    }
    
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    func logWithDetails(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        var logTime: String {
            return "[\(Logger.formatter.string(from: Date()))]"
        }
        let log = OSLog(subsystem: Logger.subsystem, category: "CustomLogs")
        let logMessage = "🌐 \(logTime): \(file.components(separatedBy: "/").last ?? "") - \(function) - Line \(line) - \(message)"
        os_log("%{public}@", log: log, type: level, logMessage)
    }
    
    func logViewCycle(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logWithDetails(level: level, message: message, file: file, function: function, line: line)
    }

    func logStatistic(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logWithDetails(level: level, message: message, file: file, function: function, line: line)
    }

    func logUI(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logWithDetails(level: level, message: message, file: file, function: function, line: line)
    }

    func logNetwork(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        logWithDetails(level: level, message: "\(message)", file: file, function: function, line: line)
    }
}
