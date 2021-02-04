//
//  Symbol.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift

// Note: fetching the whole list of symbols is approx 1 MB
class Symbol: Object {
    @objc dynamic var symbol = ""
    @objc dynamic var name = ""
    @objc dynamic var isEnabled = false
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
    
    convenience init(symbol: String, name: String, isEnabled: Bool) {
        self.init()
        self.symbol = symbol
        self.name = name
        self.isEnabled = isEnabled
    }
    
}
