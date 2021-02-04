//
//  DataService.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class DataService {
    
    private init() {}
    
    private static let base = "https://api.iextrading.com/1.0/"
    private static let exchangeRatesUrl = "https://jsonblob.com/api/8b792a70-7186-11e8-bca6-6f5d23d52c94"
    
    static let defaultValue: Double  = -69
    
    // args: additional arguments to pass to individual endpoints
    // for example, range for charts: ["range": "1d"]
    private static func batchUrlPath(symbols: [String], types: [String], args: [String:String]) -> String {
        var argsQuery = ""
        for arg in args {
            argsQuery += "&\(arg.key)=\(arg.value)"
        }
        return "stock/market/batch?symbols=\(symbols.joined(separator: ","))&types=\(types.joined(separator: ","))\(argsQuery)"
    }
    
    private static func getUrl(_ path: String) -> URL {
        return URL(string: base + path)!
    }
    
    // fetch the list of symbols and information, used for search completion
    // this does not save the data into realm
    static func fetchAllSymbols(completion: @escaping ([Symbol]?) -> Void) {
        Alamofire.request(getUrl("ref-data/symbols")).responseJSON { (response) in
            guard let symbols = parseSymbols(response: response) else {
                completion(nil)
                return
            }
            completion(symbols)
        }
    }
    
    static func parseSymbols(response: DataResponse<Any>) -> [Symbol]? {
        guard let dictList = response.result.value as? [[String:Any]] else {
            return nil
        }
        var symbols = [Symbol]()
        for dict in dictList {
            guard let symbol = dict["symbol"] as? String,
                let name = dict["name"] as? String,
                let isEnabled = dict["isEnabled"] as? Bool
            else {
                return nil
            }
            symbols.append(Symbol(symbol: symbol, name: name, isEnabled: isEnabled))
        }
        return symbols
    }
    
    // fetch news
    static func fetchStockNews(symbols: [String], completion: @escaping ([String:[News]]?) -> Void) {
        if symbols.count == 0 {
            completion([:])
            return
        }
        let url = getUrl(batchUrlPath(symbols: symbols, types: ["news"], args: [:]))
        Alamofire.request(url).responseJSON { (response) in
            guard let dicts = response.result.value as? [String:[String:Any]],
                let news = parseStockNews(dicts)
            else {
                completion(nil)
                return
            }
            completion(news)
        }
    }
    
    // returns a dict of (Symbol: [News])
    static func parseStockNews(_ dicts: [String:[String:Any]]) -> [String: [News]]? {
        var newsDict = [String:[News]]()
        for (symbol, value) in dicts {
            var newsArr = [News]()
            guard let newsData = value["news"] as? [[String:String]?] else { print("error 1"); return nil}
            for i in 0..<newsData.count {
                guard let singleNews = newsData[i],
                    let dateTime = singleNews["datetime"],
                    let date = Date.fromNews(dateTime),
                    let headLine = singleNews["headline"],
                    let source = singleNews["source"],
                    let url = singleNews["url"],
                    let summary = singleNews["summary"],
                    let related = singleNews["related"]
                else {
                    continue
                }
                let new = News(date: date, headLine: headLine, source: source, url: url, summary: summary, related: related)
                newsArr.append(new)
            }
            newsDict[symbol] = newsArr
        }
        return newsDict
    }
    
    // combines all news into an array, then sorted by latest to earliest
    static func combineNews(_ newsDict: [String:[News]]) -> [News] {
        var totalNews = [News]()
        for (_, newsArr) in newsDict {
            for news in newsArr {
                // compares news by headline
                if !totalNews.contains(where: { (news2) -> Bool in
                    return news.headLine == news2.headLine
                }) {
                    totalNews.append(news)
                }
            }
        }
        totalNews.sort { (news1, news2) -> Bool in
            return news1.date > news2.date
        }
        return totalNews
    }
    
    static func fetchExchangeRates(completion: @escaping ([String:Double]?)->Void) {
        guard let url = URL(string: exchangeRatesUrl) else {
            completion(nil)
            return
        }
        Alamofire.request(url).responseJSON { (response) in
            guard let data = response.result.value as? [String:Any],
                let rates = data["rates"] as? [String:Double]
            else {
                completion(nil)
                return
            }
            completion(rates)
        }
    }
    
    // uses batch to fetch
    static func fetchStockQuotes(symbols: [String], completion: @escaping ([StockQuote]?) -> Void) {
        if symbols.count == 0 {
            completion([])
            return
        }
        let url = getUrl(batchUrlPath(symbols: symbols, types: ["quote"], args: [:]))
        Alamofire.request(url).responseJSON { (response) in
            guard let dicts = response.result.value as? [String:[String:Any]],
                let quotes = parseStockQuotes(dicts)
            else {
                completion(nil)
                return
            }
            completion(quotes)
        }
    }
    
    static func parseStockQuotes(_ dicts: [String:[String:Any]]) -> [StockQuote]? {
        var quotes = [StockQuote]()
        for (_, value) in dicts {
            guard let quoteInfo = value["quote"] as? [String:Any],
                let symbol = quoteInfo["symbol"] as? String,
                let companyName = quoteInfo["companyName"] as? String,
                let open = Double(quoteInfo["open"]),
                let openTime = Double(quoteInfo["openTime"]),
                let close = Double(quoteInfo["close"]),
                let closeTime = Double(quoteInfo["closeTime"]),
                let latestPrice = Double(quoteInfo["latestPrice"]),
                let latestUpdate = Double(quoteInfo["latestUpdate"]),
                let latestVolume = Double(quoteInfo["latestVolume"]),
                let previousClose = Double(quoteInfo["previousClose"]),
                let change = Double(quoteInfo["change"]),
                let changePercent = Double(quoteInfo["changePercent"]),
                let avgTotalVolume = Double(quoteInfo["avgTotalVolume"]),
                let marketCap = Double(quoteInfo["marketCap"]),
                let week52High = Double(quoteInfo["week52High"]),
                let week52Low = Double(quoteInfo["week52Low"])
            else {
                return nil
            }
            let high = Double(quoteInfo["high"]) ?? defaultValue
            let low = Double(quoteInfo["low"]) ?? defaultValue
            let peRatio = Double(quoteInfo["peRatio"]) ?? defaultValue
            let quote = StockQuote(value: [symbol, companyName, open, openTime, close, closeTime, high, low, latestPrice, latestUpdate, latestVolume, previousClose, change, changePercent, avgTotalVolume, marketCap, peRatio, week52High, week52Low])
            quotes.append(quote)
        }
        return quotes
    }
    
    static func fetchStockChart(symbol: String, range: ChartRange, completion: @escaping (StockChart?) -> Void) {
        if range == .d5 {
            // special case (5 day) - have to fetch individual dates for the last 5 trading days
            // should have from anywhere to 4* - 5* as much data points as individual days
            // fetch for latest date
            fetchStockChart(symbol: symbol, range: .d1) { (chart) in
                if let chart = chart {
                    // starts checking from the previous day of latest date
                    guard let checkingDate = Date(fromString: chart.data.first!.dateStr, format: "yyyy-MM-dd HH:mm")?.previousDay else {
                        completion(nil)
                        return
                    }
                    // starts checking dates recursively and fetching data
                    fetchStockChartData(symbol: symbol, date: checkingDate, daysDone: 1, daysChecked: 0, completion: { (data) in
                        guard let data = data else {
                            // fetch failed
                            completion(nil)
                            return
                        }
                        // successfully fetched all 5 days
                        let list = List<StockChartData>()
                        for chartData in data {
                            // add to list
                            list.append(chartData)
                        }
                        for chartData in chart.data {
                            list.append(chartData)
                        }
                        let d5Chart = StockChart(value: [symbol, range.rawValue, "\(symbol)-\(range.rawValue)", list])
                        completion(d5Chart)
                    })
                } else {
                    // failed fetching latest day
                    completion(nil)
                    return
                }
            }
            return // to avoid going into below - normal case
        }
        // not 5 day - normal case
        Alamofire.request(getUrl("stock/\(symbol)/chart/\(range.rawValue)")).responseJSON { (response) in
            guard let dictList = response.result.value as? [[String:Any]],
                let chart = parseStockChart(dictList, symbol: symbol, range: range)
            else {
                completion(nil)
                return
            }
            completion(chart)
        }
    }
    // recursive - goes on until daysChecked >= 10 or daysDone >= 5
    // fetches stock chart (1d) for a certain date
    private static func fetchStockChartData(symbol: String, date: Date, daysDone: Int, daysChecked: Int, completion: @escaping ([StockChartData]?) -> Void) {
        // end of recursion conditions
        if daysChecked >= 5 {
            // done, successful
            completion([])
            return
        } else if daysChecked >= 10 {
            // done, failed
            completion(nil)
            return
        }
        let dateStr = date.toString(format: "yyyyMMdd")
        Alamofire.request(getUrl("stock/\(symbol)/chart/date/\(dateStr)")).responseJSON(completionHandler: { (response) in
            // checks current date data
            guard let dictList = response.result.value as? [[String:Any]],
                let chart = parseStockChart(dictList, symbol: symbol, range: .d1)
            else {
                 // either fetch fail or date is not trading day
                fetchStockChartData(symbol: symbol, date: date.previousDay, daysDone: daysDone, daysChecked: daysChecked + 1, completion: { (arr) in
                    guard let arr = arr else {
                        completion(nil)
                        return
                    }
                    completion(arr)
                })
                return
            }
            // fetch successful for this date
            let data = chart.data.map({ (chartData) -> StockChartData in
                return chartData
            })
            fetchStockChartData(symbol: symbol, date: date.previousDay, daysDone: daysDone + 1, daysChecked: daysChecked + 1, completion: { (arr) in
                // checks if arr exist
                // if it does, it means recursion is finished and fetched successfully
                // otherwise, it means it failed (completion with nil) at some point
                guard let arr = arr else {
                    completion(nil)
                    return
                }
                // complete with the combined data set
                completion(arr + data)
            })
        })
    }
    
    static func parseStockChart(_ dictList: [[String:Any]], symbol: String, range: ChartRange) -> StockChart? {
        let chart = StockChart(value: [symbol, range.rawValue, "\(symbol)-\(range.rawValue)", List<StockChartData>()])
        for dict in dictList {
            if let chartData = parseStockChartData(dict, range: range) {
                chartData.chart = chart // sets inverse relation
                chart.data.append(chartData)
            }
        }
        if chart.data.count < 10 {
            return nil
        }
        return chart
    }
    static func parseStockChartData(_ dict: [String:Any], range: ChartRange) -> StockChartData? {
        // different ranges have different date formats
        var dateStr = ""
        if range == .d1 || range == .d5 {
            // has two parts: date (yyyyMMdd) and minute (HH:mm)
            // combine them into yyyy-MM-dd HH:mm
            guard let date = dict["date"] as? String,
                let minute = dict["minute"] as? String,
                let dateAndTime = Date(fromString: "\(date)\(minute)", format: "yyyyMMddHH:mm")
            else { return nil }
            dateStr = dateAndTime.toString(format: "yyyy-MM-dd HH:mm")
        } else {
            // date is yyyy-MM-dd format
            guard let str = dict["date"] as? String,
                let _ = Date(fromString: str, format: "yyyy-MM-dd") // check if it is valid date str
            else { return nil }
            dateStr = str
            
        }
        guard let open = Double(dict["open"]),
            let high = Double(dict["high"]),
            let low = Double(dict["low"]),
            let close = Double(dict["close"]),
            let volume = Double(dict["volume"])
        else {
            return nil
        }
        return StockChartData(value: [dateStr, open, high, low, close, volume, nil])
    }
    
    static func roundLargeDouble(number: Double) -> String {
        var resString: String = ""
        if number / 1000000 <= 0.1 {
            resString = String(round(number))
        } else if number / 1000000000 <= 0.1 {
            resString = String(roundToSigFig(number, to: 4) / 1000000) + "M"
        } else {
            resString = String(roundToSigFig(number, to: 4) / 1000000000) + "B"
        }
        return resString
    }
    
    static func roundToSigFig(_ num: Double, to places: Int) -> Double {
        let p = log10(abs(num))
        let f = pow(10, p.rounded() - Double(places) + 1)
        let rnum = (num / f).rounded() * f
        
        return rnum
    }
    
}

enum ChartRange: String {
    case d1 = "1d"
    case d5 = "5d"
    case m1 = "1m"
    case m6 = "6m"
    case y1 = "1y"
    case y5 = "5y"
}

