//
//  MajorTimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

enum MajorTimeZone: String, Codable, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case honolulu = "Pacific/Honolulu"
    case anchorage = "America/Anchorage"
    case losAngeles = "America/Los_Angeles"
    case denver = "America/Denver"
    case chicago = "America/Chicago"
    case newYork = "America/New_York"
    case halifax = "America/Halifax"
    case saoPaulo = "America/Sao_Paulo"
    case stJohns = "America/St_Johns"
    
    case azores = "Atlantic/Azores"
    case london = "Europe/London"
    case paris = "Europe/Paris"
    case athens = "Europe/Athens"
    case moscow = "Europe/Moscow"
    
    case tehran = "Asia/Tehran"
    case dubai = "Asia/Dubai"
    case karachi = "Asia/Karachi"
    case kolkata = "Asia/Kolkata"
    case kathmandu = "Asia/Kathmandu"
    case dhaka = "Asia/Dhaka"
    
    case bangkok = "Asia/Bangkok"
    case shanghai = "Asia/Shanghai"
    case tokyo = "Asia/Tokyo"
    
    case adelaide = "Australia/Adelaide"
    case sydney = "Australia/Sydney"
    case auckland = "Pacific/Auckland"
    case tongatapu = "Pacific/Tongatapu"
    
    // MARK: - Базовые свойства
    
    var id: String { rawValue }
    var identifier: String { rawValue }
}
