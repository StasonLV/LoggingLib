// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog

public extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let viewCycle = Logger(subsystem: subsystem, category: "ViewcycleLogging")
    static let statistics = Logger(subsystem: subsystem, category: "StatisticsLogging")
    static let ui = Logger(subsystem: subsystem, category: "InterfaceLogging")
    static let network = Logger(subsystem: subsystem, category: "NetworkLogging")
    
    func logWithDetails(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let formatter = DateFormatter()
        var logTime: String {
            formatter.dateFormat = "HH:mm:ss"
            return "[\(formatter.string(from: Date()))]"
        }
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CustomLogs")
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
