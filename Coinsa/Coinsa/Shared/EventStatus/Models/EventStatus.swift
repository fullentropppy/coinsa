//
//  EventStatus.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum EventStatus: String, Codable, CaseIterable {
    case upcoming
    case ongoing
    case completed
}
