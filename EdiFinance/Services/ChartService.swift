//
//  ChartService.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-09.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import Charts

class ChartService {
    
    private init() {}
    
}

// formatter for the x axis (date/time)
class DateAxisFormatter: IAxisValueFormatter {
    
    var chart: StockChart
    
    init(chart: StockChart) {
        self.chart = chart
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if value < 0 || Int(value) >= chart.data.count || (chart.range == "5d" && 5*Int(value) >= chart.data.count) {
            return ""
        }
        
        // input
        let originalFormat = Date.dateFormatForRange(chart.range)
        
        // output
        var outputFormat = ""
        switch chart.range {
        case "1d":
            // displays hour such as 1:00 PM
            outputFormat = "h:mm a"
        case "5d":
            // May 6
            outputFormat = "h a, MMM d"
        case "1m", "6m", "1y", "5y":
            // May 6, 18
            outputFormat = "MMM d, yy"
        default:
            print("Invalid range")
        }
        
        var dateStr = ""
        if chart.range == "5d" {
            dateStr = chart.data[5*Int(value)].dateStr
        } else {
            dateStr = chart.data[Int(value)].dateStr
        }
        guard let date = Date(fromString: dateStr, format: originalFormat) else { return "" }
        
        return date.toString(format: outputFormat)
    }
    
}
