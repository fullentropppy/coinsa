//
//  Currency+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension Currency: LabelProviding {
    /// Стиль метки для валюты (текст с кодом и названием).
    var labelSyle: LabelView.Style {
        .withText(title: localizedResource, text: code)
    }
}
