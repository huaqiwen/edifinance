//
//  RealmService.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    private init() {}
    
    // to find .realm file
    // https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file
    
    static let realm = try! Realm()
    
    static func getFilePath() -> URL {
        return Realm.Configuration.defaultConfiguration.fileURL!
    }
    
    static func deleteAll(completion: ((_ success: Bool) -> Void)?) {
        let success = (try? realm.write {
            realm.deleteAll()
        }) != nil
        completion?(success)
    }
    
    static func saveCurrencies(currencies: [Currency], completion: ((_ success: Bool) -> Void)?) {
        let success = (try? realm.write {
            for currency in currencies {
                realm.add(currency, update: true)
            }
        }) != nil
        completion?(success)
    }
    
    static func getSortedCurrencies() -> [Currency] {
        return realm.objects(Currency.self).sorted(byKeyPath: "code").map({ (currency) -> Currency in
            return currency
        })
    }
    
    static func saveSymbols(symbols: [Symbol], completion: ((_ success: Bool) -> Void)?) {
        let success = (try? realm.write {
            for symbol in symbols {
                realm.add(symbol, update: true)
            }
        }) != nil
        completion?(success)
    }
    // sorted by symbol, from A -> Z, if isEnabled is true
    static func getSortedSymbols() -> [Symbol] {
        return realm.objects(Symbol.self).sorted(byKeyPath: "symbol").map({ (symbol) -> Symbol in
            return symbol
        }).filter({ (symbol) -> Bool in
            return symbol.isEnabled
        })
    }
    
    static func saveStockQuotes(quotes: [StockQuote], completion: ((_ success: Bool) -> Void)?) {
        let success = (try? realm.write {
            for quote in quotes {
                realm.add(quote, update: true)
            }
        }) != nil
        completion?(success)
    }
    
    static func getStockQuotes() -> [StockQuote] {
        return realm.objects(StockQuote.self).map({ (quote) -> StockQuote in
            return quote
        })
    }
    static func getStockQuote(symbol: String) -> StockQuote? {
        return realm.object(ofType: StockQuote.self, forPrimaryKey: symbol)
    }
    static func getStockQuotes(symbols: [String]) -> [StockQuote]? {
        var quotes = [StockQuote]()
        for symbol in symbols {
            guard let quote = getStockQuote(symbol: symbol) else {
                return nil
            }
            quotes.append(quote)
        }
        return quotes
    }
    
    static func getCurrency(code: String) -> Currency? {
        return realm.object(ofType: Currency.self, forPrimaryKey: code)
    }
    
    static func deleteStockQuote(symbol: String, completion: ((_ success: Bool) -> Void)?) {
        let success = (try? realm.write {
            if let quote = getStockQuote(symbol: symbol) {
                realm.delete(quote)
            }
            }) != nil
        completion?(success)
    }
    
    // since stock chart contains instances of other managed objects:
    // see if an instance of same StockChart exists. If it does, clear its ChartData
    // then, add the new instance / update
    static func updateStockChart(_ chart: StockChart, completion: ((_ success: Bool) -> Void)?) {
        realm.beginWrite()
        if let existing = getStockChart(symbol: chart.symbol, range: chart.range) {
            // a local version exists - clear its data by iterating through
            for data in existing.data {
                realm.delete(data)
            }
        }
        realm.add(chart, update: true)
        let success = (try? realm.commitWrite()) != nil
        completion?(success)
    }
    // the primary key for StockData is symbol-range
    static func getStockChart(symbol: String, range: String) -> StockChart? {
        return realm.object(ofType: StockChart.self, forPrimaryKey: "\(symbol)-\(range)")
    }
    
    // MARK: - UserDefaults section
    static func updateSavedSymbols(_ symbols: [String]) {
        UserDefaults.standard.set(symbols, forKey: "symbols")
    }
    static func getSavedSymbols() -> [String] {
        guard let symbols = UserDefaults.standard.array(forKey: "symbols") as? [String] else {
            // initialize with some defaults
            let symbols = ["AAPL", "GOOG", "MSFT", "AMZN", "FB"]
            updateSavedSymbols(symbols)
            return symbols
        }
        return symbols
    }
    
    static func getSavedExchangeRates() -> [String:Double]? {
        guard let rates = UserDefaults.standard.dictionary(forKey: "exchangeRates") as? [String:Double] else {
            return nil
        }
        return rates
    }
    static func saveExchangeRates(_ rates: [String:Double]) {
        UserDefaults.standard.set(rates, forKey: "exchangeRates")
    }
    
    static func updateSavedCurrencies(_ currencies: [String]) {
        UserDefaults.standard.set(currencies, forKey: "currencies")
    }
    static func getSavedCurrencies() -> [String] {
        guard let currencies = UserDefaults.standard.array(forKey: "currencies") as? [String] else {
            // initialize with some defaults
            let currencies = ["AUD", "CNY", "CAD", "EUR", "AED"]
            updateSavedCurrencies(currencies)
            return currencies
        }
        return currencies
    }
    
}
