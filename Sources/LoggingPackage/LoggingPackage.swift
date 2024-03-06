// Logging Package
//
// https://github.com/StasonLV/LoggingPackage

import OSLog

protocol LoggingInterface {
    static func log(
        for category: Categories,
        with message: String,
        priority level: OSLogType,
        file: String,
        function: String,
        line: Int,
        appendToFile: Bool
    )
}

final public class Logging: LoggingInterface {
    
    private static var subsystem: String! {
        didSet {
            makeLoggers()
        }
    }
    private static let sharedInstance: Logging = {
        let instance = Logging()
        subsystem = Bundle.main.bundleIdentifier ?? "undefinedSubsystemBundle"
        return instance
    }()

    private static var networkLogger: Logger?
    private static var viewcycleLogger: Logger?
    private static var userInterfaceLogger: Logger?
    private static var statisticsLogger: Logger?
    private static var privateFileLogger: Logger?
    private static var socketLogger: Logger?
    
    init() {
        Logging.subsystem = Bundle.main.bundleIdentifier ?? "undefinedSubsystemBundle"
        print("Logger INITIALIZED")
    }
    
    deinit {
        Logging.log(for: .privateFileLogging, with: "LOGGER DEINITIALIZED", priority: .fault)
        print("Logger DEINITIALIZED")
    }
    ///  Создаем логгеры для каждой категории логгирования при первом обращении к функции log()(метод приватный).
    ///
    private static func makeLoggers() {
        Logging.networkLogger = Logger(subsystem: subsystem, category: Categories.networkLogging.rawValue)
        Logging.viewcycleLogger = Logger(subsystem: subsystem, category: Categories.viewcycleLogging.rawValue)
        Logging.userInterfaceLogger = Logger(subsystem: subsystem, category: Categories.userInterfaceLogging.rawValue)
        Logging.statisticsLogger = Logger(subsystem: subsystem, category: Categories.statisticsLogging.rawValue)
        Logging.privateFileLogger = Logger(subsystem: subsystem, category: Categories.privateFileLogging.rawValue)
        Logging.socketLogger = Logger(subsystem: subsystem, category: Categories.socketLogging.rawValue)
    }
    ///  Получаем логгер в зависимости от переданной категории(метод приватный).
    ///
    /// - Parameters:
    ///   - category: категория логгирования.
    private static func getLogger(for category: Categories) -> Logger {
        switch category {
        case .viewcycleLogging:
            return viewcycleLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        case .userInterfaceLogging:
            return userInterfaceLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        case .networkLogging:
            return networkLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        case .statisticsLogging:
            return statisticsLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        case .privateFileLogging:
            return privateFileLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        case .socketLogging:
            return socketLogger ?? Logger(subsystem: subsystem, category: category.rawValue)
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    ///  Log a message with the specified category, message, priority, and additional information.
    ///
    /// - Parameters:
    ///   - category: The category of the log.
    ///   - message: The log message.
    ///   - level: The priority level of the log.
    ///   - file: The file path. By default, it is automatically filled with the calling file path.
    ///   - function: The function name. By default, it is automatically filled with the calling function name.
    ///   - line: The line number. By default, it is automatically filled with the calling line number.
    ///   - appendToFile: Specify if you want to add it to log.txt file.
    public static func log(
        for category: Categories,
        with message: String,
        priority level: OSLogType,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        appendToFile: Bool = false
    ) {
        let _ = sharedInstance
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)][\(URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent) on line: \(line)] - \(function)\n LOG MESSAGE:\n\(message)"
        
        let logger = getLogger(for: category)
        
        switch level {
        case .fault:
            logger.critical("\(logMessage)")
            
        case .error:
            logger.error("\(logMessage)")
            
        case .debug:
            logger.debug("\(logMessage)")
            
        case .default:
            logger.log("\(logMessage)")
            
        case .info:
            logger.info("\(logMessage)")
            
        default:
            logger.log("\(logMessage)")
        }
        
        if appendToFile {
            writeLogToFile(log: logMessage, for: category)
        }
    }
    /// Write log message into log.txt file with the specified category, message, priority, and additional information.
    ///
    /// - Parameters:
    ///   - log: Content of the log file.
    private static func writeLogToFile(log: String, for category: Categories) {
#if DEBUG
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
            return
        }
        
        let logFileURL = documentsDirectory.appendingPathComponent("\(category.rawValue).txt")
        
        do {
            let textToWrite = "\(log)\n"
            
            if let fileHandle = FileHandle(forWritingAtPath: logFileURL.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(textToWrite.data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                try textToWrite.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
            
            self.log(for: .privateFileLogging, with: "Log successfully appended to file \(logFileURL)", priority: .default)

        } catch {
            self.log(for: .privateFileLogging, with: "Failed to write log to file: \(error.localizedDescription)", priority: .error)
        }
#endif
    }
    /// Check contents of log.txt file.
    ///
    private static func checkFileContent() {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("log.txt") else {
            log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
            return
        }
        
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            log(for: .privateFileLogging, with: "Log file content:\n\(fileContent)", priority: .default)

        } catch {
            log(for: .privateFileLogging, with: "Error reading log file content: \(error.localizedDescription)", priority: .error)
        }
    }
    
    internal static func iconForCategory(_ category: Categories) -> String {
        switch category {
        case .viewcycleLogging:
            return "🔄"
        case .userInterfaceLogging:
            return "⚙️"
        case .networkLogging:
            return "🌐"
        case .statisticsLogging:
            return "📊"
        case .privateFileLogging:
            return "♿️"
        case .socketLogging:
            return "📶"
        }
    }
}

public enum Categories: String {
    /// - viewcycleLogging: Логирование событий жизненного цикла контроллеров или приложения.
    case viewcycleLogging = "viewcycleLogging"
    /// - userInterfaceLogging: Логирование событий пользовательского интерфейса.
    case userInterfaceLogging = "userInterfaceLogging"
    /// - networkLogging: Логирование событий сетевого взаимодействия.
    case networkLogging = "networkLogging"
    /// - statisticsLogging: Общая категория логирования для неспецифичных событий и статистики.
    case statisticsLogging = "statisticsLogging"
    /// - privateFileLogging: Приватная категория для обработки записи/чтения логов в файл.
    case privateFileLogging = "privateFileLogging"
    /// - privateFileLogging: Приватная категория для обработки записи/чтения логов в файл.
    case socketLogging = "socketLogging"
}
//
//extension Logger {
//    /// Категории лог-файлов для различных типов логирования.
//    public enum Categories: String {
//        /// - viewcycleLogging: Логирование событий жизненного цикла контроллеров или приложения.
//        case viewcycleLogging = "viewcycleLogging"
//        /// - userInterfaceLogging: Логирование событий пользовательского интерфейса.
//        case userInterfaceLogging = "userInterfaceLogging"
//        /// - networkLogging: Логирование событий сетевого взаимодействия.
//        case networkLogging = "networkLogging"
//        /// - statisticsLogging: Общая категория логирования для неспецифичных событий и статистики.
//        case statisticsLogging = "statisticsLogging"
//        /// - privateFileLogging: Приватная категория для обработки записи/чтения логов в файл.
//        case privateFileLogging = "privateFileLogging"
//    }
//    /// Идентификатор бандла для поиска и фильтрации в Console.app.
//    private static var subsystem = Bundle.main.bundleIdentifier!
//    /// Форматтер времени для лог файла.
//    private static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter
//    }()
//    /// Log a message with the specified category, message, priority, and additional information.
//    ///
//    /// - Parameters:
//    ///   - category: The category of the log.
//    ///   - message: The log message.
//    ///   - level: The priority level of the log.
//    ///   - file: The file path. By default, it is automatically filled with the calling file path.
//    ///   - function: The function name. By default, it is automatically filled with the calling function name.
//    ///   - line: The line number. By default, it is automatically filled with the calling line number.
//    ///   - appendToFile: Specify if you want to add it to log.txt file.
//    public static func log(
//        for category: Categories,
//        with message: String,
//        priority level: OSLogType,
//        file: String = #file,
//        function: String = #function,
//        line: Int = #line,
//        appendToFile: Bool = false
//    ) {
//        let logTime = dateFormatter.string(from: Date())
//        let logMessage = "\(iconForCategory(category)) [\(logTime)][\(URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent) on line: \(line)] - \(function)\n LOG MESSAGE:\n\(message)"
//        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category.rawValue), type: level, logMessage)
//        if appendToFile {
//            writeLogToFile(log: logMessage)
//            checkFileContent()
//        }
//    }
//    /// Write log message into log.txt file with the specified category, message, priority, and additional information.
//    ///
//    /// - Parameters:
//    ///   - log: Content of the log file.
//    private static func writeLogToFile(log: String) {
//#if DEBUG
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            self.log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
//            return
//        }
//        
//        let logFileURL = documentsDirectory.appendingPathComponent("log.txt")
//        
//        do {
//            let textToWrite = "\(log)\n"
//            
//            if let fileHandle = FileHandle(forWritingAtPath: logFileURL.path) {
//                fileHandle.seekToEndOfFile()
//                fileHandle.write(textToWrite.data(using: .utf8)!)
//                fileHandle.closeFile()
//            } else {
//                try textToWrite.write(to: logFileURL, atomically: true, encoding: .utf8)
//            }
//            
////            self.log(for: .privateFileLogging, with: "Log successfully appended to file", priority: .default)
//
//        } catch {
//            self.log(for: .privateFileLogging, with: "Failed to write log to file: \(error.localizedDescription)", priority: .error)
//        }
//#endif
//    }
//    /// Check contents of log.txt file.
//    ///
//    private static func checkFileContent() {
//        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("log.txt") else {
//            log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
//            return
//        }
//        
//        do {
//            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
//            log(for: .privateFileLogging, with: "Log file content:\n\(fileContent)", priority: .default)
//
//        } catch {
//            log(for: .privateFileLogging, with: "Error reading log file content: \(error.localizedDescription)", priority: .error)
//        }
//    }
//    /// Clears log file (log.txt).
//    ///
//    public static func clearLogFile() {
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
//            return
//        }
//        
//        let logFileURL = documentsDirectory.appendingPathComponent("log.txt")
//        
//        do {
//            try FileManager.default.removeItem(at: logFileURL)
//            log(for: .privateFileLogging, with: "Log file cleared successfully", priority: .default)
//        } catch {
//            log(for: .privateFileLogging, with: "Failed to clear log file: \(error.localizedDescription)", priority: .default)
//        }
//    }
//
//    /// Add icon to log depending on selected category.
//    ///
//    /// - Parameters:
//    ///   - category: The category of the log.
//    ///
//    /// - Returns:
//    ///  Returns icon according to log type.
//    internal static func iconForCategory(_ category: Categories) -> String {
//        switch category {
//        case .viewcycleLogging:
//            return "🔄"
//        case .userInterfaceLogging:
//            return "⚙️"
//        case .networkLogging:
//            return "🌐"
//        case .statisticsLogging:
//            return "📊"
//        case .privateFileLogging:
//            return "♿️"
//        }
//    }
//}
