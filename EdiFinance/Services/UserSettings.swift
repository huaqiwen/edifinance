//
//  UserSettings.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-22.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

struct UserSettings {
    static var savedSymbols = RealmService.getSavedSymbols() {
        didSet {
            RealmService.updateSavedSymbols(savedSymbols)
        }
    }
    
    static var savedCurrencies = RealmService.getSavedCurrencies() {
        didSet {
            RealmService.updateSavedCurrencies(savedCurrencies)
        }
    }
    
    static var displayCompactNews = UserDefaults.standard.bool(forKey: "displayCompactNews") {
        didSet {
            UserDefaults.standard.set(displayCompactNews, forKey: "displayCompactNews")
        }
    }
    
    static var autoRefreshInterval = UserDefaults.standard.integer(forKey: "refreshTimeInterval") {
        didSet {
            UserDefaults.standard.set(autoRefreshInterval, forKey: "refreshTimeInterval")
        }
    }
    
    static var baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency") ?? "USD" {
        didSet {
            UserDefaults.standard.set(baseCurrency, forKey: "baseCurrency")
        }
    }
    
    static var themeIndex = UserDefaults.standard.integer(forKey: "themeIndex") {
        didSet {
            UserDefaults.standard.set(themeIndex, forKey: "themeIndex")
            // updates theme in themeable views
            Theme.current = Theme.themes[UserSettings.themeIndex]
            for view in Theme.themeables {
                view.applyTheme(theme: Theme.current)
            }
            UIApplication.shared.statusBarStyle = Theme.current.statusBarStyle
        }
    }
    
}
