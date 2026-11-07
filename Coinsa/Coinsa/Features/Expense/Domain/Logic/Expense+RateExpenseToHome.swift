//
//  Expense+RateExpenseToHome.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.11.2026.
//

extension Expense {
    /// Курс обмена валюты траты к домашней валюты.
    /// На переходный период для переименования rateExpenseToBase в rateExpenseToHome.
    var rateExpenseToHome: Double {
        rateExpenseToBase
    }
}
