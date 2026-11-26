//
//  DataTransferDocument.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import SwiftUI
import UniformTypeIdentifiers

/// Системный документ для сохранения переносимого JSON-снимка.
nonisolated struct DataTransferDocument: FileDocument {
    // MARK: - Тип документа и содержимое

    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    // MARK: - Инициализация

    /// Создает документ из уже проверенного и закодированного снимка.
    /// - Parameter data: JSON-содержимое переносимых записей.
    init(data: Data) {
        self.data = data
    }

    /// Читает документ, ограничивая размер до декодирования.
    /// - Parameter configuration: Конфигурация системного документа.
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw DataTransferError.invalidFile }
        guard data.count <= DataTransferCodec.maximumFileSize else { throw DataTransferError.fileTooLarge }
        self.data = data
    }

    // MARK: - Запись документа

    /// Передает подготовленное содержимое системному диалогу экспорта без повторного кодирования.
    /// - Parameter configuration: Параметры записи системного документа.
    /// - Returns: Файловая обертка полного снимка Coinsa.
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }

    // MARK: - Чтение выбранного файла

    /// Координирует доступ к выбранному файлу и ограничивает память при чтении до декодирования.
    /// - Parameter url: URL из системного диалога с возможным security-scoped доступом.
    /// - Returns: Декодированные записи; внешние родители новых трат проверяются при подготовке плана.
    static func read(from url: URL) throws -> DataTransferArchive {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }
        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var result: Result<DataTransferArchive, Error> = .failure(DataTransferError.invalidFile)
        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { readableURL in
            result = Result {
                let file = try FileHandle(forReadingFrom: readableURL)
                defer { try? file.close() }
                var data = Data()
                while true {
                    try Task.checkCancellation()
                    let remaining = DataTransferCodec.maximumFileSize + 1 - data.count
                    guard remaining > 0 else { throw DataTransferError.fileTooLarge }
                    guard let chunk = try file.read(upToCount: min(remaining, 64 * 1_024)), !chunk.isEmpty else { break }
                    data.append(chunk)
                    guard data.count <= DataTransferCodec.maximumFileSize else { throw DataTransferError.fileTooLarge }
                }
                return try DataTransferCodec.decode(data)
            }
        }
        if let coordinationError { throw coordinationError }
        return try result.get()
    }
}
