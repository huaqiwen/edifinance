//
//  SearchViewController.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-22.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit
import FontAwesome
import StatusAlert

var fromVC = "home"

class SearchViewController: UIViewController {
    
    var symbols: [Symbol] = RealmService.getSortedSymbols()
    var displayingSymbols: [Symbol] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currencies: [Currency] = RealmService.getSortedCurrencies()
    var displayingCurrencies: [Currency] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelButtonPressed(_ sender: Any) {
        view.endEditing(true)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func showSymbolStarAlert(saved: Bool, symbol: String) {
        let image = saved ? UIImage(named: "Star.png") : UIImage(named: "StarO.png")
        let title = saved ? "Saved" : "Removed"
        var message = String()
        message = saved ? "Saved stock \(symbol) to your device." :
        "Removed stock \(symbol) from your device."
        let alert = StatusAlert.instantiate(withImage: image, title: title, message: message, canBePickedOrDismissed: true)
        alert.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.9)
        alert.showInKeyWindow()
    }
    
    func showCurrencyStarAlert(saved: Bool, code: String) {
        let image = saved ? UIImage(named: "Star.png") : UIImage(named: "StarO.png")
        let title = saved ? "Saved" : "Removed"
        var message = String()
        message = saved ? "Saved stock \(code) to your device." :
        "Removed stock \(code) from your device."
        let alert = StatusAlert.instantiate(withImage: image, title: title, message: message, canBePickedOrDismissed: true)
        alert.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.9)
        alert.showInKeyWindow()
    }
    
    // does this in a separate thread so UI is not lagging
    func handleFilter(_ filter: String) {
        DispatchQueue.main.async {
            if filter == "" || filter == " " {
                if fromVC == "home" {
                    self.displayingSymbols = []
                } else {
                    self.displayingCurrencies = []
                }
                return
            }
            let lower = filter.lowercased()
            if fromVC == "home" {
                self.displayingSymbols = self.symbols.filter({ (symbol) -> Bool in
                    return symbol.symbol.lowercased().hasPrefix(lower) || symbol.name.lowercased().hasPrefix(lower) || symbol.name.lowercased().contains(" \(lower)")
                })
            } else {
                self.displayingCurrencies = self.currencies.filter({ (currency) -> Bool in
                    return currency.code.lowercased().hasPrefix(lower) || currency.name.lowercased().hasPrefix(lower) || currency.name.lowercased().contains(" \(lower)")
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableView delegate and data source
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fromVC == "home" ? displayingSymbols.count : displayingCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SearchTableViewCell else {
            return UITableViewCell()
        }
        
        cell.index = indexPath.row
        cell.delegate = self
        
        if fromVC == "home" {
            let symbol = displayingSymbols[indexPath.row]
            cell.symbolLabel.text = symbol.symbol
            cell.nameLabel.text = symbol.name
            
            cell.addButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
            let iconName = UserSettings.savedSymbols.contains(symbol.symbol) ?
                FontAwesome.star :
                FontAwesome.starO
            cell.addButton.setTitle(String.fontAwesomeIcon(name: iconName), for: .normal)
        } else {
            let currency = displayingCurrencies[indexPath.row]
            cell.symbolLabel.text = currency.code
            cell.nameLabel.text = currency.name
            cell.addButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
            let iconName = UserSettings.savedCurrencies.contains(currency.code) ? FontAwesome.star : FontAwesome.starO
            cell.addButton.setTitle(String.fontAwesomeIcon(name: iconName), for: .normal)
        }
        
        let theme = Theme.current
        cell.backgroundColor = theme.backgroundColor
        cell.symbolLabel.textColor = theme.primaryTextColor
        cell.nameLabel.textColor = theme.primaryTextColor
        cell.addButton.setTitleColor(theme.buttonColor, for: .normal)
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = theme.selectionColor
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        handleFilter(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension SearchViewController: SearchTableViewCellDelegate {
    func didPressAddButton(index: Int) {
        if fromVC == "home" {
            if index == -1 { return }
            let symbol = displayingSymbols[index].symbol
            if let position = UserSettings.savedSymbols.index(of: symbol) {
                // symbol already exists - delete it
                UserSettings.savedSymbols.remove(at: position)
            } else {
                // saves the symbol - will download when returns to HomeView
                UserSettings.savedSymbols.append(symbol)
            }
            view.endEditing(true)
            showSymbolStarAlert(saved: UserSettings.savedSymbols.contains(symbol), symbol: symbol)
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            if index == -1 { return }
            let code = displayingCurrencies[index].code
            if let position = UserSettings.savedCurrencies.index(of: code) {
                // symbol already exists - delete it
                UserSettings.savedCurrencies.remove(at: position)
            } else {
                // saves the symbol - will download when returns to HomeView
                UserSettings.savedCurrencies.append(code)
            }
            view.endEditing(true)
            showCurrencyStarAlert(saved: UserSettings.savedCurrencies.contains(code), code: code)
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}

extension SearchViewController: Themeable {
    func applyTheme(theme: Theme) {
        
        view.backgroundColor = theme.settingsBackgroundColor
        
        cancelButton.setTitleColor(theme.buttonColor, for: .normal)
        
//        searchBar.backgroundColor = theme.backgroundColor
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = theme.secondaryTextColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.selectionColor
        tableView.reloadData()
    }
}
