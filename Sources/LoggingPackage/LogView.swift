//
//  File.swift
//  
//
//  Created by Stanislav on 22.03.2024.
//

import SwiftUI

struct ListBackgroundModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

struct LogView: View {
    @State private var selectedCategory: Categories = .networkLogging
    @State var logText: String = ""

    var body: some View {
            List {
                Section(header: Text("Выберите категорию логов")) {
                    Picker("Категория", selection: $selectedCategory.animation()) {
                        ForEach(Categories.allCases) { category in
                            Text(category.rawValue.capitalized)
                        }
                    }
                    .onAppear(perform: {
                        getFileContents(category: selectedCategory)
                    })
                    .onChange(of: selectedCategory) { newCategory in
                        getFileContents(category: newCategory)
                    }
                }
                //            .listRowBackground(Color.clear)
                Section {
                    HStack(alignment: .center, spacing: 60) {
                            Button(action: {
                                shareSheet(url: selectedCategory)
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundColor(.white)
                            .frame(width: 50, height: 20)
                            .padding(10)
                            .background(Color.primary)
                            .cornerRadius(10)

                            Button(action: {
                                UIPasteboard.general.string = logText
                            }) {
                                Image(systemName: "doc.on.doc")
                            }
                            .foregroundColor(.white)
                            .frame(width: 50, height: 20)
                            .padding(10)
                            .background(Color.primary)
                            .cornerRadius(10)

                        Button(action: {
                                clearFileContent(category: selectedCategory)
                            }) {
                                Image(systemName: "clear")
                            }
                            .foregroundColor(.white)
                            .frame(width: 50, height: 20)
                            .padding(10)
                            .background(Color.primary)
                            .cornerRadius(10)
                        }
                    }
                .listRowBackground(Color.clear)
//                .frame(width: .infinity, height: 20)

                if logText != "" {
                    Section(header: Text("Контент лог файла")) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text(logText).frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        UIPasteboard.general.string = logText
                                }
                            }
                        }
                    }
                } else {
                    Text("Лог файл пуст")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .listStyle(InsetGroupedListStyle()) // Используем стиль .insetGrouped для таблицы
            .modifier(ListBackgroundModifier())
            .background(.ultraThinMaterial)
    }
    
    func getFileContents(category: Categories) {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(category.rawValue).txt") else {
//            log(for: .privateFileLogging, with: "Log file (socketLogging.txt) not found", priority: .error)
            logText = ""
            return
        }
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
//            log(for: .privateFileLogging, with: "Log file content:\n\(fileContent)", priority: .default)
            logText = fileContent
        } catch {
//            log(for: .privateFileLogging, with: "Error reading log file content: \(error.localizedDescription)", priority: .error)
            logText = ""
        }
    }
    
    func clearFileContent(category: Categories) {
        do {
            guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(category.rawValue).txt") else {
                // Обработка ошибки в случае, если не удалось получить путь к файлу
                return
            }

            let emptyData = Data() // Создание пустых данных

            try emptyData.write(to: filePath, options: .atomic) // Запись пустых данных в файл
            logText = ""
            print("Содержимое файла очищено успешно")
        } catch {
            // Обработка ошибки, если не удалось записать пустые данные в файл
            print("Ошибка при очистке содержимого файла: \(error.localizedDescription)")
        }
    }

    func shareSheet(url: Categories) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(url.rawValue).txt")
        let activityView = UIActivityViewController(activityItems: [url!], applicationActivities: nil)

        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            windowScene.keyWindow?.rootViewController?.present(activityView, animated: true, completion: nil)
        }

    }
}

#Preview {
    LogView()
}
