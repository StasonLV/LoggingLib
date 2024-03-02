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
/// Log a message with the specified category, message, priority, and additional information.
///
/// - Parameters:
///   - category: The category of the log.
///   - message: The log message.
///   - level: The priority level of the log.
///   - file: The file path. By default, it is automatically filled with the calling file path.
///   - function: The function name. By default, it is automatically filled with the calling function name.
///   - line: The line number. By default, it is automatically filled with the calling line number.

    public static func log(
        for category: Categories,
        with message: String,
        priority level: OSLogType,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)][\(URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent) on line: \(line)] - \(function) - \(message)"
        
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
