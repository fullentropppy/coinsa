//
//  AppReleaseVersion.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.11.2026.
//

import Foundation

/// Числовая версия и сборка приложения с учетом незначащих завершающих нулей.
struct AppReleaseVersion {
    // MARK: - Свойства

    private let versionComponents: [Int]
    private let buildComponents: [Int]

    // MARK: - Инициализация

    /// Создает сравнимую пару из одной–трех числовых компонент версии и сборки.
    /// - Parameters:
    ///   - version: Пользовательская версия, например `1.1`.
    ///   - build: Номер сборки, например `12`.
    init?(version: String, build: String) {
        guard let versionComponents = Self.components(from: version),
              let buildComponents = Self.components(from: build) else { return nil }
        self.versionComponents = versionComponents
        self.buildComponents = buildComponents
    }

    // MARK: - Методы

    func isNewer(than other: AppReleaseVersion) -> Bool {
        if versionComponents != other.versionComponents {
            return other.versionComponents.lexicographicallyPrecedes(versionComponents)
        }
        return other.buildComponents.lexicographicallyPrecedes(buildComponents)
    }

    private static func components(from value: String) -> [Int]? {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...3).contains(parts.count) else { return nil }

        var result: [Int] = []
        for part in parts {
            guard !part.isEmpty,
                  part.utf8.allSatisfy({ (48...57).contains($0) }),
                  let number = Int(part) else { return nil }
            result.append(number)
        }
        while result.count > 1 && result.last == 0 {
            result.removeLast()
        }
        return result
    }
}
