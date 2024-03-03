// Logging Package
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
    }
    /// Идентификатор бандла для поиска и фильтрации в Console.app..
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
        }
    }
}

public struct TextLogger {
    public static func writeLogToFile(text: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let logFileURL = documentsDirectory.appendingPathComponent("log.txt")
        
        do {
            let textToWrite = "\(Date()): \(text)\n"
            
            if let fileHandle = FileHandle(forWritingAtPath: logFileURL.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(textToWrite.data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                try textToWrite.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
            
            print("Log successfully appended to file!")
            
        } catch {
            print("Failed to write log to file: \(error.localizedDescription)")
        }
    }

    public static func checkFileContent() {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("log.txt") else {
            print("Файл не найден")
            return
        }
        
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            print("Содержимое файла:")
            print(fileContent)
        } catch {
            print("Ошибка чтения файла: \(error.localizedDescription)")
        }
    }

}
