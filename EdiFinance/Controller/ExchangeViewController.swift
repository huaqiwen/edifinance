//
//  ExchangeViewController.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-31.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var topPartGroupView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var baseSymbolLabel: UILabel!
    @IBOutlet weak var baseNameLabel: UILabel!
    @IBOutlet weak var baseValueTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func baseValueChanged(_ sender: Any) {
        if let value = Double(baseValueTextField.text!) {
            baseValue = value
        } else if baseValueTextField.text == "" {
            baseValue = 0
        }
    }
    
    var baseValue: Double = 100.0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var exchangeRates: [String:Double] = [:] // rate to EUR
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        updateLabels()
        
        fetchCurrencyRates { (rates) in
            if let rates = rates {
                self.exchangeRates = rates
                RealmService.saveExchangeRates(rates)
            } else {
                // TODO: No internet connection and no local data
                if let local = self.loadCurrencyRates() {
                    self.exchangeRates = local
                } else {
                    // no data stored locally
                }
            }
            self.tableView.reloadData()
        }
        
        // 点按屏幕其他位置时回收键盘
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExchangeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
//        baseCurrency = RealmService.getCurrency(code: UserSettings.baseCurrency)!
//        let savedCurrenciesArr: [String] = UserSettings.savedCurrencies
//        for code in savedCurrenciesArr {
//            let currency = RealmService.getCurrency(code: code)
//            exchangeCurrencies.append(currency!)    // 每次保存确保货币代码存在，可以!
//        }
        //print(exchangeCurrencies)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        guard let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
        return
        }
        fromVC = "exchange"
        
        searchVC.searchBar?.becomeFirstResponder()
        present(searchVC, animated: true, completion: nil)
    }
    
    func updateLabels() {
        baseSymbolLabel.text = UserSettings.baseCurrency
        baseNameLabel.text = RealmService.getCurrency(code: UserSettings.baseCurrency)?.name ?? "--"
    }
    
    // fetch rates from API
    func fetchCurrencyRates(completion: @escaping ([String:Double]?)->Void) {
        DataService.fetchExchangeRates { (rates) in
            guard let rates = rates else {
                completion(nil)
                return
            }
            completion(rates)
        }
    }
    // load rates saved locally
    func loadCurrencyRates() -> [String:Double]? {
        if let localRates = RealmService.getSavedExchangeRates() {
            return localRates
        }
        return nil
    }
    
    func loadCurrencyInfo(for currencies: [String]) -> [String:Currency] {
        var info = [String:Currency]()
        for currency in currencies {
            info[currency] = RealmService.getCurrency(code: currency)
        }
        return info
    }
    
    @IBAction func tfEditingChanged(_ sender: UITextField) {
        if sender.text != nil {
            baseValue = (sender.text! as NSString).doubleValue
            tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension ExchangeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSettings.savedCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exccell", for: indexPath) as? ExchangeTableViewCell else { return UITableViewCell() }
        
        let currency = UserSettings.savedCurrencies[indexPath.row]
        if let info = RealmService.getCurrency(code: currency) {
            cell.symbol.text = info.code
            cell.name.text = "\(info.name)  \(info.nativeSymbol)"
        }
        if let rate = exchangeRates[currency], let baseRate = exchangeRates[UserSettings.baseCurrency] {
            let value = (rate * baseValue / baseRate).rounded(2)
            cell.value.text = "\(value)"
        } else {
            cell.value.text = "--"
        }
        
        let theme = Theme.current
        cell.symbol.textColor = theme.primaryTextColor
        cell.value.textColor = theme.primaryTextColor
        cell.name.textColor = theme.secondaryTextColor
        cell.backgroundColor = theme.backgroundColor
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = theme.selectionColor
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        let currency = UserSettings.savedCurrencies[indexPath.row]
        if let rate = exchangeRates[currency], let baseRate = exchangeRates[UserSettings.baseCurrency] {
            baseValue = rate * baseValue / baseRate
            baseValueTextField.text = baseValue.rounded(2)
        }
        UserSettings.savedCurrencies[indexPath.row] = UserSettings.baseCurrency
        UserSettings.baseCurrency = currency
        
        updateLabels()
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Exchange"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = Theme.current.secondaryTextColor
            headerView.backgroundView?.backgroundColor = Theme.current.settingsBackgroundColor
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            UserSettings.savedCurrencies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [delete]
    }
    
}

extension ExchangeViewController: Themeable {
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        topPartGroupView.backgroundColor = theme.backgroundColor
        baseNameLabel.textColor = theme.secondaryTextColor
        baseSymbolLabel.textColor = theme.primaryTextColor
        baseValueTextField.textColor = theme.primaryTextColor
        addButton.backgroundColor = theme.settingsBackgroundColor
        addButton.setTitleColor(theme.buttonColor, for: .normal)
        navigationController?.navigationBar.barTintColor = theme.barColor
        navigationController?.navigationBar.tintColor = theme.buttonColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.selectionColor
        tableView.reloadSectionIndexTitles()
        tableView.reloadData()
    }
}


















