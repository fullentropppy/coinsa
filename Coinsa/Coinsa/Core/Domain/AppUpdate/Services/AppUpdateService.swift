//
//  AppUpdateService.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.11.2026.
//

import Foundation

/// Загрузка публичной конфигурации обновлений без использования устаревшего локального кеша.
struct AppUpdateService {
    private let session: URLSession

    /// Создает сервис с возможностью подмены сети в изолированных проверках.
    /// - Parameter session: Сессия для получения JSON.
    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUpdate() async throws -> AppUpdateInfo {
        var request = URLRequest(
            url: AppUpdateConfig.endpoint,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: AppUpdateConfig.requestTimeout
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Coinsa/\(AppInfo.version) (\(AppInfo.build))", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let info = try JSONDecoder().decode(AppUpdateInfo.self, from: data)
        guard info.isSupported else { throw URLError(.cannotParseResponse) }
        return info
    }
}
