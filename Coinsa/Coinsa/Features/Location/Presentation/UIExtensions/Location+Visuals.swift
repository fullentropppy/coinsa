//
//  Location+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Location: TypeVisualRepresentable {
    static var primaryIcon: String { "mappin.and.ellipse" }
    static var secondaryIcon: String { primaryIcon }
    static var accentColor: Color { .pink }
}
