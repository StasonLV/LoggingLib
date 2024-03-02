// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog

extension Logger {
    private enum Categories: String {
        case viewcycleLogging = "viewcycleLogging"
        case userInterfaceLogging = "userInterfaceLogging"
        case networkLogging = "networkLogging"
        case statisticsLogging = "statisticsLogging"
    }
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    private static func iconForCategory(_ category: Categories) -> String {
        switch category {
            case .viewcycleLogging:
                return "🔄"
            case .userInterfaceLogging:
                return "⚙️"
            case .networkLogging:
                return "🌐"
            case .statisticsLogging:
                return "📊"
        }
    }

    private static func logWithDetails2(for category: Categories,
                                        with message: String,
                                       priority level: OSLogType,
                                        file: String = #file,
                                        function: String = #function,
                                        line: Int = #line
    ) {
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)] [\(file.components(separatedBy: "/").last ?? ""):\(line)] - \(function) - \(message)"

        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category.rawValue), type: level, logMessage)
    }
    
    private static func logWithDetails(category: Categories,
                                       level: OSLogType,
                                       message: String,
                                       file: String,
                                       function: String,
                                       line: Int
    ) {
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)] [\(file.components(separatedBy: "/").last ?? ""):\(line)] - \(function) - \(message)"

        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category.rawValue), type: level, logMessage)
    }
    
    public static func logViewCycle(level: OSLogType, 
                                    message: String,
                                    file: String = #file,
                                    function: String = #function,
                                    line: Int = #line
    ) {
        let category = Categories.viewcycleLogging
        logWithDetails(category: category, level: level, message: message, file: file, function: function, line: line)
    }
    
    public static func logStatistics(level: OSLogType, 
                                     message: String,
                                     file: String = #file,
                                     function: String = #function,
                                     line: Int = #line
    ) {
        let category = Categories.statisticsLogging
        logWithDetails(category: category, level: level, message: message, file: file, function: function, line: line)
    }
    
    public static func logUI(level: OSLogType, 
                             message: String,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line
    ) {
        let category = Categories.userInterfaceLogging
        logWithDetails(category: category, level: level, message: message, file: file, function: function, line: line)
    }
    
    public static func logNetwork(level: OSLogType, 
                                  message: String,
                                  file: String = #file,
                                  function: String = #function,
                                  line: Int = #line
    ) {
        let category = Categories.networkLogging
        logWithDetails(category: category, level: level, message: message, file: file, function: function, line: line)
    }
}

//
//public extension Logger {
//    
//    private static var subsystem = Bundle.main.bundleIdentifier!
//    private static var formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter
//    }()
//
//    static var viewCycle: Logger {
//        Logger(subsystem: subsystem, category: "ViewcycleLogging")
//    }
//    
//    static var statistics: Logger {
//        Logger(subsystem: subsystem, category: "StatisticsLogging")
//    }
//    
//    static var ui: Logger {
//        Logger(subsystem: subsystem, category: "InterfaceLogging")
//    }
//    
//    static var network: Logger {
//        Logger(subsystem: subsystem, category: "NetworkLogging")
//    }
//    
//    func logWithDetails(level: OSLogType, message: String, file: String = #file, function: String = #function, line: Int = #line) {
//        var logTime: String {
//            return "[\(Logger.formatter.string(from: Date()))]"
//        }
//        let log = OSLog(subsystem: Logger.subsystem, category: "CustomLogs")
//        let logMessage = "🌐 \(logTime): \(file.components(separatedBy: "/").last ?? "") - \(function) - Line \(line) - \(message)"
//        os_log("%{public}@", log: log, type: level, logMessage)
//    }
//    
//    func logViewCycle(level: OSLogType, 
//                      message: String,
//                      file: String = #file,
//                      function: String = #function,
//                      line: Int = #line
//    ) {
//        logWithDetails(level: level, message: message, file: file, function: function, line: line)
//    }
//
//    func logStatistic(level: OSLogType, 
//                      message: String,
//                      file: String = #file,
//                      function: String = #function,
//                      line: Int = #line
//    ) {
//        logWithDetails(level: level, message: message, file: file, function: function, line: line)
//    }
//
//    func logUI(level: OSLogType, 
//               message: String,
//               file: String = #file,
//               function: String = #function,
//               line: Int = #line
//    ) {
//        logWithDetails(level: level, message: message, file: file, function: function, line: line)
//    }
//
//    func logNetwork(level: OSLogType, 
//                    message: String,
//                    file: String = #file,
//                    function: String = #function,
//                    line: Int = #line
//    ) {
//        logWithDetails(level: level, message: "\(message)", file: file, function: function, line: line)
//    }
//}
