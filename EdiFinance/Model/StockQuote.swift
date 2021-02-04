//
//  StockQuote.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-07.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift

class StockQuote: Object {
    // time in this object are milliseconds since Jan 1, 1970 (unix timestamp)
    // to convert to Date, divide by 1000 first (to become seconds), then use Date(timeIntervalSince1970:)
    @objc dynamic var symbol = ""
    @objc dynamic var companyName = ""
    @objc dynamic var open = 0.0
    @objc dynamic var openTime = 0.0
    @objc dynamic var close = 0.0
    @objc dynamic var closeTime = 0.0
    @objc dynamic var high = 0.0
    @objc dynamic var low = 0.0
    @objc dynamic var latestPrice = 0.0
    @objc dynamic var latestUpdate = 0.0
    @objc dynamic var latestVolume = 0.0
    @objc dynamic var previousClose = 0.0 // if market is still open, this is same as close
    @objc dynamic var change = 0.0
    @objc dynamic var changePercent = 0.0
    @objc dynamic var avgTotalVolume = 0.0 // average volume for 30 days
    @objc dynamic var marketCap = 0.0
    @objc dynamic var peRatio = 0.0
    @objc dynamic var week52High = 0.0
    @objc dynamic var week52Low = 0.0
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}
