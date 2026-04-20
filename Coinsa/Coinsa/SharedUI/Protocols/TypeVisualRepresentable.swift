//
//  TypeVisualRepresentable.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

protocol TypeVisualRepresentable {
    static var primaryIcon: String { get }
    static var secondaryIcon: String { get }
    static var accentColor: Color { get }
}
