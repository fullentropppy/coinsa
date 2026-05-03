//
//  PaymentMethod+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension PaymentMethod: LabelProviding {
    /// Стиль метки для способа оплаты (иконка с фиксированной шириной).
    var labelSyle: LabelView.Style {
        .withIcon(title: localizedResource, icon: primaryIcon, iconWidth: 28)
    }
}
