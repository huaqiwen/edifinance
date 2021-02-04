//
//  News.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-27.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation

class News {
    var date: Date
    var headLine: String = ""
    var source: String = ""
    var url: String = ""
    var summary: String = ""
    var related: String = ""
    
    init(date: Date, headLine: String, source: String, url: String, summary: String, related: String) {
        self.date = date
        self.headLine = headLine
        self.source = source
        self.url = url
        self.summary = summary
        self.related = related
    }
}
