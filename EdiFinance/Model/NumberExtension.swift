//
//  DoubleExtension.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-07.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation

// convenience initializers for easy data parsing in DataService

extension Double {
    init?(_ value: Any?) {
        guard let number = value as? NSNumber else { return nil }
        self = number.doubleValue
    }
    func rounded(_ dp: Int) -> String {
        return NSString(format: "%.2f", self) as String
    }
}

extension Int {
    init?(_ value: Any?) {
        guard let number = value as? NSNumber else { return nil }
        self = number.intValue
    }
}
