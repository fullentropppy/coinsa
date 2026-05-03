//
//  AsyncTimeout.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import Foundation

/// Утилита для выполнения асинхронных операций с ограничением по времени.
struct AsyncTimeout {
    /// Выполняет асинхронную операцию с таймаутом.
    /// - Parameters:
    ///   - seconds: Максимальное время выполнения операции в секундах.
    ///   - operation: Асинхронное замыкание для выполнения.
    /// - Returns: Результат операции типа `T`.
    /// - Throws: `TimeoutError`, если операция не завершилась за отведенное время.
    static func run<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Ошибки

/// Ошибка, возникающая при превышении времени ожидания операции.
struct TimeoutError: LocalizedError {
    var errorDescription: String? {
        String(localized: .timeoutException)
    }
}
