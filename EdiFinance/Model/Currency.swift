//
//  Currency.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-31.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift

class Currency: Object {
    @objc dynamic var code = ""
    @objc dynamic var name = ""
    @objc dynamic var nativeSymbol = ""
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    convenience init(code: String, name: String, nativeSymbol: String) {
        self.init()
        self.code = code
        self.name = name
        self.nativeSymbol = nativeSymbol
    }
}




