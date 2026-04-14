//
//  ExchangeRateManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ExchangeRateManager {
    // MARK: - Свойства
    
    private let provider: ExchangeRateProvider
    private var refreshTask: Task<Void, Never>?
    
    var isRateLoading = false
    var rateLoadingError: ExchangeRateLoadingError?
    
    // MARK: - Инициализация
    
    init(provider: ExchangeRateProvider) {
        self.provider = provider
    }
    
    // MARK: - Публичные методы
    
    func requestRefresh(
        from: Currency,
        to: Currency,
        onRateUpdate: @escaping @MainActor (Double) -> Void
    ) {
        cancelRefresh()
        if from != to {
            refreshTask = Task {
                await refreshRate(from: from, to: to, onRateUpdate: onRateUpdate)
            }
        }
    }
    
    func cancelRefresh() {
        refreshTask?.cancel()
        isRateLoading = false
        rateLoadingError = nil
    }
    
    // MARK: - Приватные методы
    
    private func refreshRate(
        from: Currency,
        to: Currency,
        onRateUpdate: @escaping @MainActor (Double) -> Void
    ) async {
        isRateLoading = true
        rateLoadingError = nil
        
        do {
            let rate = try await provider.getRate(from: from, to: to)
            try Task.checkCancellation()
            onRateUpdate(rate)
        } catch is CancellationError {
            return
        } catch let error as TimeoutError {
            rateLoadingError = ExchangeRateLoadingError(details: error.errorDescription)
        } catch {
            rateLoadingError = ExchangeRateLoadingError()
        }
        
        isRateLoading = false
    }
}
