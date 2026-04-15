//
//  Currency+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import Foundation

extension Currency: LabelProviding {
    var labelTitle: LocalizedStringResource { self.localizedResource }
    var labelBadgeFrameWidth: Double { 38 }
    var labelBadgeText: String? { self.code }
}
