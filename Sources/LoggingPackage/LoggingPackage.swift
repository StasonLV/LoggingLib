// Logging Package
//
// https://github.com/StasonLV/LoggingPackage

import OSLog

extension Logger {
    /// Категории лог-файлов для различных типов логирования.
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
    }
    /// Идентификатор бандла для поиска и фильтрации в Console.app.
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Форматтер времени для лог файла.
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
        let logTime = dateFormatter.string(from: Date())
        let logMessage = "\(iconForCategory(category)) [\(logTime)][\(URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent) on line: \(line)] - \(function) - \(message)"
        
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category.rawValue), type: level, logMessage)
        if appendToFile {
            writeLogToFile(log: logMessage)
            checkFileContent()
        }
    }
    /// Write log message into log.txt file with the specified category, message, priority, and additional information.
    ///
    /// - Parameters:
    ///   - log: Content of the log file.
    private static func writeLogToFile(log: String) {
#if DEBUG
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
            return
        }
        
        let logFileURL = documentsDirectory.appendingPathComponent("log.txt")
        
        do {
            let textToWrite = "\(Date()): \(log)\n"
            
            if let fileHandle = FileHandle(forWritingAtPath: logFileURL.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(textToWrite.data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                try textToWrite.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
            
//            self.log(for: .privateFileLogging, with: "Log successfully appended to file!", priority: .default)

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
    /// Clears log file (log.txt).
    ///
    public static func clearLogFile() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            log(for: .privateFileLogging, with: "Log file (log.txt) not found", priority: .error)
            return
        }
        
        let logFileURL = documentsDirectory.appendingPathComponent("log.txt")
        
        do {
            try FileManager.default.removeItem(at: logFileURL)
//            log(for: .privateFileLogging, with: "Log file cleared successfully", priority: .default)
        } catch {
            log(for: .privateFileLogging, with: "Failed to clear log file: \(error.localizedDescription)", priority: .default)
        }
    }

    /// Add icon to log depending on selected category.
    ///
    /// - Parameters:
    ///   - category: The category of the log.
    ///
    /// - Returns:
    ///  Returns icon according to log type.
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
        }
    }
}
