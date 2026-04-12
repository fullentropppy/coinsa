//
//  PaymentMethod+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import Foundation

extension PaymentMethod {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .cash: .paymentMethodCash
        case .card: .paymentMethodCard
        }
    }
}
