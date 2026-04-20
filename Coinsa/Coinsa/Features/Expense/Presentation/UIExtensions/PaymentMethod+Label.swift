//
//  PaymentMethod+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension PaymentMethod: LabelProviding {
    var labelSyle: LabelView.Style {
        .withIcon(title: localizedResource, icon: primaryIcon, iconWidth: 28)
    }
}
