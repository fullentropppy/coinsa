//
//  AppInfo.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import Foundation

struct AppInfo {
    static private var firstSupportedYear: Int { 2026 }
    static private var lastSupportedYear: Int { 2026 }
    
    static var copyrightYears: String {
        if firstSupportedYear == lastSupportedYear {
            return "© \(lastSupportedYear)"
        } else {
            return "© \(firstSupportedYear)-\(lastSupportedYear)"
        }
    }
    
    static var authorName: String {
        NSLocalizedString("app.author", comment: "")
    }
    
    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
