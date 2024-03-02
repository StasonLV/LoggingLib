// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog

extension Logger {
    public enum Categories: String {
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
    
    public static func log(
        for category: Categories,
        with message: String,
        priority level: OSLogType,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)] [\(file.components(separatedBy: "/").last ?? ""):\(line)] - \(function) - \(message)"
        
        print(subsystem)
        
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category.rawValue), type: level, logMessage)
    }
}

//MARK: Icon managment

private extension Logger {
    static func iconForCategory(_ category: Categories) -> String {
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
}
