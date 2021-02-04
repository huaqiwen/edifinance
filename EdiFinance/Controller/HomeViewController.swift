//
//  HomeViewController.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-05.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit
import SVProgressHUD
import ESPullToRefresh
import StatusAlert

let greenColor = UIColor.init(red: 0.3255, green: 0.8471, blue: 0.4118, alpha: 1.0)
let redColor = UIColor.init(red: 0.9922, green: 0.2392, blue: 0.2157, alpha: 1.0)

//var savedStocks: [StockQuote] = []

class HomeViewController: UIViewController {
    
    var displayingQuotes: [StockQuote] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var marketCap: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var infoTitles: [UILabel]!
    @IBOutlet var infoTexts: [UILabel]!
    
    var timer: Timer!
    var currentInfoIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(RealmService.getFilePath())
        
        // 检测网络连接
        if Reachability.isConnectedToNetwork() {
            print("connected")
        } else {
            print("not connected")
        }
        
        if UserSettings.autoRefreshInterval == 0 {
            UserSettings.autoRefreshInterval = 5
        }
        
        // downloads all symbols for search autocomplete
        if RealmService.getSortedSymbols().count == 0 {
            SVProgressHUD.show()
            DataService.fetchAllSymbols { (symbols) in
                if let symbols = symbols {
                    RealmService.saveSymbols(symbols: symbols, completion: nil)
                } else {
                    // TODO: - Error message - internet for initial download (of ~1MB)
                    print("error fetching all symbols")
                }
            }
            SVProgressHUD.dismiss()
        }
        
        // parse all currencies
        if RealmService.getSortedCurrencies().count == 0 {
            if let path = Bundle.main.path(forResource: "currency", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    //print(jsonResult)
                    var currencies: [Currency] = []
                    if let jsonResult = jsonResult as? Dictionary<String, Dictionary<String, Any>> {
                        for singleData in jsonResult {
                            let currency = Currency()
                            //print(singleData)
                            let value = singleData.value
                            currency.code = value["code"] as! String
                            currency.name = value["name"] as! String
                            currency.nativeSymbol = value["symbol_native"] as! String
                            currencies.append(currency)
                        }
                        RealmService.saveCurrencies(currencies: currencies) { (status) in
                            if !status {
                                print("error saving currecies to Realm")
                            }
                        }
                    }
                } catch {
                    print("parse error: \(error.localizedDescription)")
                }
            }
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        displayingQuotes = RealmService.getStockQuotes(symbols: UserSettings.savedSymbols) ?? []
        
        refreshQuotes { (status) in
            if status == false { print("error") }
        }
        
        self.tableView.es.addPullToRefresh {
            self.refreshQuotes(completion: { (status) in
                if status == false { print("error") }
                self.tableView.es.stopPullToRefresh()
            })
        }
        
        if UserSettings.autoRefreshInterval != -69 {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(UserSettings.autoRefreshInterval), target: self, selector: #selector(refreshQuotesWOCompletion), userInfo: nil, repeats: true)
        }
        
        // Apply current theme and subscribe to theme changes
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            destination.displayingSymbol = displayingQuotes[(tableView.indexPathForSelectedRow?.row)!].symbol
            destination.displayingQuote = displayingQuotes[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        // 检查网络链接
        if Reachability.isConnectedToNetwork() {
            guard let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
                return
            }
            fromVC = "home"
            
            searchVC.searchBar?.becomeFirstResponder()
            present(searchVC, animated: true, completion: nil)
        } else {
            let alert = StatusAlert.instantiate(withImage: UIImage(named: "nowifi.png"), title: "No Connection", message: "Please check your internet connection and try again.", canBePickedOrDismissed: true)
            alert.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.9)
            alert.showInKeyWindow()
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        guard let senderCell = sender.superview?.superview as? HomeTableViewCell else { return }
        let indexRow = tableView.indexPath(for: senderCell)!.row
        self.currentInfoIndex = indexRow
        updateBasicInfo(quote: displayingQuotes[currentInfoIndex])
    }
    
    func updateBasicInfo(quote: StockQuote) {
        open.text = quote.open == -69 ? "-" : String(quote.open)
        marketCap.text = quote.marketCap == -69 ? "-" : String(DataService.roundLargeDouble(number: quote.marketCap))
        volume.text = quote.latestVolume == -69 ? "-" : String(DataService.roundLargeDouble(number: quote.latestVolume))
        high.text = quote.high == -69 ? "-" : String(DataService.roundToSigFig(quote.high, to: 5))
        low.text = quote.low == -69 ? "-" : String(DataService.roundToSigFig(quote.low, to: 5))
        change.text = quote.change == -69 ? "-" : String(DataService.roundToSigFig(quote.change, to: 5))
    }
    
    // updates displayingQuotes with the symbols in savedSymbols
    func refreshQuotes(completion: ((Bool) -> Void)?) {
        DataService.fetchStockQuotes(symbols: UserSettings.savedSymbols) { (quotes) in
            if let quotes = quotes {
                RealmService.saveStockQuotes(quotes: quotes, completion: { (success) in
                    self.displayingQuotes = RealmService.getStockQuotes(symbols: UserSettings.savedSymbols)!
                    self.tableView.reloadData()
                })
            } else {
                // TODO: - Error message - fail to refresh
                
            }
            if self.currentInfoIndex >= self.displayingQuotes.count {
                self.currentInfoIndex = 0
            }
            self.updateBasicInfo(quote: self.displayingQuotes[self.currentInfoIndex])
            
            completion?(true)
        }
    }
    
    @objc
    func refreshQuotesWOCompletion() {
        refreshQuotes(completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarStyle
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingQuotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let quote = displayingQuotes[indexPath.row]
        cell.symbol.text = quote.symbol
        cell.name.text = quote.companyName
        cell.changePerc.text = String(quote.changePercent * 100) + "%"
        cell.price.text = String(quote.latestPrice)
        
        cell.changePerc.cornerRadius = 8
        
        let theme = Theme.current
        cell.changePerc.backgroundColor = quote.change >= 0 ? theme.increaseColor : theme.decreaseColor
        cell.changePerc.textColor = quote.change >= 0 ? theme.increaseTextColor : theme.decreaseTextColor
        cell.backgroundColor = theme.backgroundColor
        cell.symbol.textColor = theme.primaryTextColor
        cell.name.textColor = theme.secondaryTextColor
        cell.price.textColor = theme.primaryTextColor
        cell.infoButton.tintColor = theme.buttonColor
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = theme.selectionColor
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            RealmService.deleteStockQuote(symbol: self.displayingQuotes[indexPath.row].symbol, completion: { (success) in
                if success {
                    UserSettings.savedSymbols.remove(at: indexPath.row)
                    self.displayingQuotes.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.refreshQuotes(completion: nil)
                } else {
                    // TODO: - Failed to delete message
                    print("Failed to delete")
                }
            })
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "homeToDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.view.endEditing(true)
        displayingQuotes = RealmService.getStockQuotes(symbols: UserSettings.savedSymbols) ?? []
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            let lw = searchText.lowercased()
            let storedQuotes = RealmService.getStockQuotes(symbols: UserSettings.savedSymbols) ?? []
            displayingQuotes = []
            if storedQuotes.count > 0 {
                for quote in storedQuotes {
                    if quote.companyName.lowercased().contains(lw) || quote.symbol.lowercased().contains(lw) {
                        displayingQuotes.append(quote)
                    }
                }
            }
            tableView.reloadData()
        } else {
            displayingQuotes = RealmService.getStockQuotes(symbols: UserSettings.savedSymbols) ?? []
            tableView.reloadData()
        }
    }
}

extension HomeViewController: Themeable {
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        navigationController?.navigationBar.barTintColor = theme.barColor
        navigationController?.navigationBar.tintColor = theme.buttonColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.selectionColor
        tableView.reloadData() // refresh cell themes
        
        infoView.backgroundColor = theme.backgroundColor
        for label in infoTitles {
            label.textColor = theme.secondaryTextColor
        }
        for label in infoTexts {
            label.textColor = theme.primaryTextColor
        }
        
        let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInSearchBar?.textColor = theme.primaryTextColor
        
        navigationController?.tabBarController?.tabBar.barTintColor = theme.barColor
        navigationController?.tabBarController?.tabBar.tintColor = theme.buttonColor
    }
}












