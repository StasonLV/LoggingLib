// Logging Package
//
// https://github.com/StasonLV/LoggingPackage

import OSLog
import SwiftUI
///  Протокол для интерфейса взаимодействия с классом Logger.
///
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
    static func showModalView(navController: UINavigationController)
}

final public class Logging: LoggingInterface {
    public static func showModalView(navController: UINavigationController) {

        let contentView = LogView()
                
        let modalView = AnyView(contentView)
        
        let hostingController = UIHostingController(rootView: modalView)
        hostingController.modalPresentationStyle = .formSheet
        hostingController.sheetPresentationController?.prefersGrabberVisible = true
        hostingController.view.backgroundColor = .clear
        navController.pushViewController(hostingController, animated: true)
//        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//            let window = windowScene.windows.first,
//            let rootViewController = window.rootViewController,
//            let navigationController = rootViewController.navigationController {
//            navigationController.present(hostingController, animated: true)
//        }
    }

    private static var subsystem: String! {
        didSet {
            makeLoggers()
        }
    }
    ///  Приватный SharedInstance, необоходимый для первичной инициализации в подключенном проекте с бандлом текущего проекта(для сортировки в Console.app).
    ///
    private static let sharedInstance: Logging = {
        let instance = Logging()
        subsystem = Bundle.main.bundleIdentifier ?? "undefinedSubsystemBundle"
        
        return instance
    }()
    static weak var sharedWeakInstance: Logging? = sharedInstance

    private static var networkLogger: Logger?
    private static var viewcycleLogger: Logger?
    private static var userInterfaceLogger: Logger?
    private static var statisticsLogger: Logger?
    private static var privateFileLogger: Logger?
    private static var socketLogger: Logger?

    init() {
        Logging.subsystem = Bundle.main.bundleIdentifier ?? "undefinedSubsystemBundle"
        
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
    /// Получение иконки в лог в соответствии с категорией.
    ///
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

public enum Categories: String, CaseIterable, Identifiable {
    public var id: Self { self }
    
    /// - viewcycleLogging: Логирование событий жизненного цикла контроллеров или приложения.
    case viewcycleLogging = "viewcycle Logging"
    /// - userInterfaceLogging: Логирование событий пользовательского интерфейса.
    case userInterfaceLogging = "userInterface Logging"
    /// - networkLogging: Логирование событий сетевого взаимодействия.
    case networkLogging = "network Logging"
    /// - statisticsLogging: Общая категория логирования для неспецифичных событий и статистики.
    case statisticsLogging = "statistics Logging"
    /// - privateFileLogging: Приватная категория для обработки записи/чтения логов в файл.
    case privateFileLogging = "privateFile Logging"
    /// - privateFileLogging: Приватная категория для обработки записи/чтения логов в файл.
    case socketLogging = "socket Logging"
}
