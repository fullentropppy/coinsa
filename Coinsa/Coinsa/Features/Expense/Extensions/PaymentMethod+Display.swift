//
//  PaymentMethod+Display.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import Foundation

extension PaymentMethod {
    var labelIcon: String {
        switch self {
        case .cash: "banknote"
        case .card: "creditcard"
        }
    }
}
