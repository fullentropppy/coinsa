//
//  Int+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.04.2026.
//

import Foundation

extension Int {
    func isBetween(_ first: Int, and second: Int) -> Bool {
        self >= first && self <= second
    }
}
