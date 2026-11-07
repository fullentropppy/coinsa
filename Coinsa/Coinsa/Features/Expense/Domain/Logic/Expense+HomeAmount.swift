//
//  Expense+HomeAmount.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.11.2026.
//

extension Expense {
    /// Курс обмена валюты траты к домашней валюты.
    /// На переходный период для переименования baseAmount в homeAmount.
    var homeAmount: Double {
        baseAmount
    }
}
