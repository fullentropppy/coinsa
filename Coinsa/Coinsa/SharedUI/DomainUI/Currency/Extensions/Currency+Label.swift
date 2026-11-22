//
//  Currency+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension Currency: LabelProviding {
    // MARK: - Свойства

    /// Стиль метки для валюты (текст с кодом и названием).
    var labelStyle: ItemLabel.Style {
        .withText(title: localizedResource, text: code)
    }
}
