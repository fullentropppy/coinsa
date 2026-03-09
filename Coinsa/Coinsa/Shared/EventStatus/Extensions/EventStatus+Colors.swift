//
//  EventStatus+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

extension EventStatus {
    var color: Color {
        switch self {
        case .upcoming: .blue
        case .ongoing: .green
        case .completed: .gray
        }
    }
}
