//
//  StockChart.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-07.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift
import Charts

class StockChart: Object {
    @objc dynamic var symbol = ""
    @objc dynamic var range = "" // 1d, 5d, 1m, 6m, 1y, 5y
    @objc dynamic var key = "" // this should be "\(symbol)-\(range)"
    let data = List<StockChartData>()
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    func candleChartDataSet() -> CandleChartDataSet {
        var entries = [CandleChartDataEntry]()
        for i in 0..<data.count {
            let chartData = data[i]
            entries.append(CandleChartDataEntry(x: Double(i+1), shadowH: chartData.high, shadowL: chartData.low, open: chartData.open, close: chartData.close))
        }
        
        let dataSet = CandleChartDataSet(values: entries, label: "\(symbol) \(range)")
        
        dataSet.increasingFilled = true
        dataSet.increasingColor = UIColor.green
        dataSet.decreasingFilled = true
        dataSet.decreasingColor = UIColor.red
        dataSet.shadowColor = UIColor.gray
        dataSet.shadowWidth = 1
        
        return dataSet
    }
    
    func lineChartDataSet() -> LineChartDataSet {
        var entries = [ChartDataEntry]()
        for chartData in data {
            // if 5d, only take data for every 5 min - mm ending with 0 or 5
            if !(range == "5d") || chartData.dateStr.last! == "0" || chartData.dateStr.last! == "5" {
                entries.append(ChartDataEntry(x: Double(entries.count), y: chartData.close))
            }
        }
        let dataSet = LineChartDataSet(values: entries, label: "\(symbol) \(range)")
        
        dataSet.drawValuesEnabled = false
        
        dataSet.circleRadius = 0
        dataSet.setColor(ChartColorTemplates.colorFromString("#3198ff"))
        
        let gradient = [ChartColorTemplates.colorFromString("#e0f3ff").cgColor,
                        ChartColorTemplates.colorFromString("#b7d6ff").cgColor]
        let gradientColor = CGGradient(colorsSpace: nil, colors: gradient as CFArray, locations: nil)!
        dataSet.fill = Fill(linearGradient: gradientColor, angle: 90)
        dataSet.drawFilledEnabled = true
        
        return dataSet
    }
    
}
