//
//  SettingsTableViewController.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-30.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    private var cellIndexExpansion: [Int : Bool] = [0 : false, 1 : false]
    
    private var autorefreshPickerData: [String] = ["3 seconds", "5 seconds", "30 seconds", "1 minute", "5 minutes", "Never"]
    private var themePickerData: [String] = Theme.themes.map { (theme) -> String in
        return theme.name
    }

    @IBOutlet weak var autorefreshLabel: UILabel!
    @IBOutlet weak var autorefreshShowButton: UIButton!
    @IBOutlet weak var autorefreshPickerView: UIPickerView!
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themePickerShowButton: UIButton!
    @IBOutlet weak var themePickerView: UIPickerView!
    
    @IBOutlet var settingsCells: [UITableViewCell]!
    @IBOutlet var settingsLabels: [UILabel]!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化图标
        autorefreshShowButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
        autorefreshShowButton.setTitle(String.fontAwesomeIcon(name: .angleDown), for: .normal)
        themePickerShowButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
        themePickerShowButton.setTitle(String.fontAwesomeIcon(name: .angleDown), for: .normal)
        
        // 去除tableView下方多余空白
        tableView.tableFooterView = UIView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
    }
    
    func reloadPickerViews() {
        // 初始化
        switch UserSettings.autoRefreshInterval {
        case 3:
            autorefreshPickerView.selectRow(0, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Every 3 Seconds"
        case 5:
            autorefreshPickerView.selectRow(1, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Every 5 Seconds"
        case 30:
            autorefreshPickerView.selectRow(2, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Every 30 Seconds"
        case 60:
            autorefreshPickerView.selectRow(3, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Every 1 Minute"
        case 300:
            autorefreshPickerView.selectRow(4, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Every 5 Minutes"
        case -69:
            autorefreshPickerView.selectRow(5, inComponent: 0, animated: true)
            autorefreshLabel.text = "    Auto Refresh Disabled"
        default:
            break
        }
        
        themePickerView.selectRow(UserSettings.themeIndex, inComponent: 0, animated: true)
        themeLabel.text = "    " + themePickerData[UserSettings.themeIndex] + " Theme"
        
        autorefreshPickerView.reloadAllComponents()
        themePickerView.reloadAllComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadPickerViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cellIndexExpansion[0] = cellIndexExpansion[0]! ? false : true
                autorefreshShowButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
                if cellIndexExpansion[0]! {
                    autorefreshShowButton.setTitle(String.fontAwesomeIcon(name: .angleUp), for: .normal)
                } else {
                    autorefreshShowButton.setTitle(String.fontAwesomeIcon(name: .angleDown), for: .normal)
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            case 1:
                cellIndexExpansion[1] = cellIndexExpansion[1]! ? false : true
                themePickerShowButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
                if cellIndexExpansion[1]! {
                    themePickerShowButton.setTitle(String.fontAwesomeIcon(name: .angleUp), for: .normal)
                } else {
                    themePickerShowButton.setTitle(String.fontAwesomeIcon(name: .angleDown), for: .normal)
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "showCredits", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return cellIndexExpansion[0]! ? 200 : 50
            case 1:
                return cellIndexExpansion[1]! ? 200 : 50
            default:
                break
            }
        default:
            break
        }
        return 50
    }
    
    @IBAction func expandButtonClicked(_ sender: UIButton) {
        let tag = sender.tag
        cellIndexExpansion[tag] = cellIndexExpansion[tag]! ? false : true
        autorefreshShowButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
        if cellIndexExpansion[tag]! {
            sender.setTitle(String.fontAwesomeIcon(name: .angleUp), for: .normal)
        } else {
            sender.setTitle(String.fontAwesomeIcon(name: .angleDown), for: .normal)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
}

extension SettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return autorefreshPickerData.count
        case 1:
            return themePickerData.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var title = ""
        switch pickerView.tag {
        case 0:
            title = autorefreshPickerData[row]
        case 1:
            title = themePickerData[row]
        default:
            title = "tag error"
        }
        return NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.foregroundColor: Theme.current.primaryTextColor
        ])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            switch row {
            case 0:
                UserSettings.autoRefreshInterval = 3
                autorefreshLabel.text = "    Auto Refresh Every 3 Seconds"
            case 1:
                UserSettings.autoRefreshInterval = 5
                autorefreshLabel.text = "    Auto Refresh Every 5 Seconds"
            case 2:
                UserSettings.autoRefreshInterval = 30
                autorefreshLabel.text = "    Auto Refresh Every 30 Seconds"
            case 3:
                UserSettings.autoRefreshInterval = 60
                autorefreshLabel.text = "    Auto Refresh Every 1 Minute"
            case 4:
                UserSettings.autoRefreshInterval = 300
                autorefreshLabel.text = "    Auto Refresh Every 5 Minutes"
            case 5:
                UserSettings.autoRefreshInterval = -69
                autorefreshLabel.text = "    Auto Refresh Disabled"
            default:
                break
            }
        case 1:
            UserSettings.themeIndex = row
            themeLabel.text = "    " + themePickerData[UserSettings.themeIndex] + " Theme"
        default:
            break
        }
    }
    
}

extension SettingsTableViewController: Themeable {
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        navigationController?.navigationBar.barTintColor = theme.barColor
        navigationController?.navigationBar.tintColor = theme.buttonColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        
        autorefreshLabel.textColor = theme.primaryTextColor
        autorefreshShowButton.tintColor = theme.secondaryTextColor
        autorefreshPickerView.backgroundColor = theme.backgroundColor
        
        themeLabel.textColor = theme.primaryTextColor
        themePickerShowButton.tintColor = theme.secondaryTextColor
        themePickerView.backgroundColor = theme.backgroundColor
        themePickerView.tintColor = UIColor.red
        reloadPickerViews()
        
        tableView.backgroundColor = theme.settingsBackgroundColor
        tableView.sectionIndexColor = theme.secondaryTextColor
        tableView.sectionIndexBackgroundColor = theme.settingsBackgroundColor
        tableView.separatorColor = theme.selectionColor
        
        for cell in settingsCells {
            cell.backgroundColor = theme.backgroundColor
            
            // sets selection color
            let selectedView = UIView(frame: cell.frame)
            selectedView.backgroundColor = theme.selectionColor
            cell.selectedBackgroundView = selectedView
        }
        for label in settingsLabels {
            label.textColor = theme.primaryTextColor
        }
        tableView.reloadData()
    }
}


// ------------------------------------------------------------------------------------------------------------------------------------
// There are very little amount of shit for this VC, thus it does not deserve to have its own file.
class CreditViewController: UIViewController, Themeable {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
        
        // Do any additional fuckings here
    }
    
    func applyTheme(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        textView.backgroundColor = theme.backgroundColor
        textView.textColor = theme.primaryTextColor
    }
}








