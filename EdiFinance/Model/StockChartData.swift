//
//  StockChartData.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-07.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift

class StockChartData: Object {
    // for 1d, dateStr combined date and minute into format yyyy-MM-dd HH:mm
    // otherwise it is just date as yyyy-MM-dd
    @objc dynamic var dateStr = ""
    @objc dynamic var open = 0.0
    @objc dynamic var high = 0.0
    @objc dynamic var low = 0.0
    @objc dynamic var close = 0.0
    @objc dynamic var volume = 0.0
    @objc dynamic var chart: StockChart?
}
