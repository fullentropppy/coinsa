//
//  PaymentMethod+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension PaymentMethod: LabelProviding {
    var labelTitle: LocalizedStringResource {
        self.localizedResource
    }
    
    var labelBadgeIcon: String? {
        switch self {
        case .cash: "banknote"
        case .card: "creditcard"
        }
    }
}
