//
//  Theme.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-07-01.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

/*
 Theme Usage:
 - conform to Themeable by adding func applyTheme(theme)
 - add the following to the end of viewDidLoad:
 
    applyTheme(Theme.current)
    Theme.themeables.append(self)
 
*/

protocol Themeable {
    func applyTheme(theme: Theme)
}

class Theme {
    var name: String
    var primaryTextColor: UIColor
    var secondaryTextColor: UIColor
    var backgroundColor: UIColor
    var buttonColor: UIColor
    var barColor: UIColor
    var barTextColor: UIColor
    var increaseColor: UIColor
    var increaseTextColor: UIColor
    var decreaseColor: UIColor
    var decreaseTextColor: UIColor
    var settingsBackgroundColor: UIColor
    var selectionColor: UIColor
    var statusBarStyle: UIStatusBarStyle
    
    init(name: String, primaryTextColor: UIColor, secondaryTextColor: UIColor, backgroundColor: UIColor, buttonColor: UIColor, barColor: UIColor, barTextColor: UIColor, increaseColor: UIColor, increaseTextColor: UIColor, decreaseColor: UIColor, decreaseTextColor: UIColor, settingsBackgroundColor: UIColor, selectionColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        
        self.name = name
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.backgroundColor = backgroundColor
        self.buttonColor = buttonColor
        self.barColor = barColor
        self.barTextColor = barTextColor
        self.increaseColor = increaseColor
        self.increaseTextColor = increaseTextColor
        self.decreaseColor = decreaseColor
        self.decreaseTextColor = decreaseTextColor
        self.settingsBackgroundColor = settingsBackgroundColor
        self.selectionColor = selectionColor
        self.statusBarStyle = statusBarStyle
    }
    
    static let themes: [Theme] = [
        Theme(name: "Default",
              primaryTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
              secondaryTextColor: #colorLiteral(red: 0.2693726206, green: 0.2693726206, blue: 0.2693726206, alpha: 1),
              backgroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              buttonColor: #colorLiteral(red: 0.26, green: 0.47, blue: 0.96, alpha: 1),
              barColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
              barTextColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
              increaseColor: #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1),
              increaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              decreaseColor: #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1),
              decreaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              settingsBackgroundColor: #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1),
              selectionColor: #colorLiteral(red: 0.8313725591, green: 0.8313725591, blue: 0.8313725591, alpha: 1),
              statusBarStyle: .default
        ),
        Theme(name: "Night",
              primaryTextColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
              secondaryTextColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),
              backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
              buttonColor: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),
              barColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
              barTextColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
              increaseColor: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1),
              increaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              decreaseColor: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1),
              decreaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              settingsBackgroundColor: #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1),
              selectionColor: #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1),
              statusBarStyle: .lightContent
        ),
        Theme(name: "Sky",
            primaryTextColor: #colorLiteral(red: 0, green: 0, blue: 0.2521430122, alpha: 1),
              secondaryTextColor: #colorLiteral(red: 0.1251356337, green: 0.3303263966, blue: 0.546359592, alpha: 1),
              backgroundColor: #colorLiteral(red: 0.9384494357, green: 0.9877929688, blue: 1, alpha: 1),
              buttonColor: #colorLiteral(red: 0.2052853733, green: 0.4145507812, blue: 0.8452539063, alpha: 1),
              barColor: #colorLiteral(red: 0.6982224153, green: 0.9162052075, blue: 0.9903559685, alpha: 1),
              barTextColor: #colorLiteral(red: 0, green: 0.3384874132, blue: 0.5631239149, alpha: 1),
              increaseColor: #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.6133083767, alpha: 1),
              increaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              decreaseColor: #colorLiteral(red: 1, green: 0.231372549, blue: 0.4803631153, alpha: 1),
              decreaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              settingsBackgroundColor: #colorLiteral(red: 0.8727181627, green: 0.9373611749, blue: 0.9944118924, alpha: 1),
              selectionColor: #colorLiteral(red: 0.8609407015, green: 0.9276453455, blue: 0.9617436528, alpha: 1),
              statusBarStyle: .default
        ),
        Theme(name: "Spring",
              primaryTextColor: #colorLiteral(red: 0.06496853299, green: 0.158203125, blue: 0, alpha: 1),
              secondaryTextColor: #colorLiteral(red: 0.173421224, green: 0.4458862924, blue: 0.321750217, alpha: 1),
              backgroundColor: #colorLiteral(red: 0.9430609808, green: 0.9877929688, blue: 0.9628363715, alpha: 1),
              buttonColor: #colorLiteral(red: 0.3023067332, green: 0.4401619402, blue: 0.1019607857, alpha: 1),
              barColor: #colorLiteral(red: 0.8308721549, green: 1, blue: 0.8895530171, alpha: 1),
              barTextColor: #colorLiteral(red: 0.1291503907, green: 0.3730468751, blue: 0.1999240452, alpha: 1),
              increaseColor: #colorLiteral(red: 0.6405681934, green: 0.9101048688, blue: 0.2470974392, alpha: 1),
              increaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              decreaseColor: #colorLiteral(red: 1, green: 0.5389626098, blue: 0.2313396778, alpha: 1),
              decreaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              settingsBackgroundColor: #colorLiteral(red: 0.9137337877, green: 0.9462890626, blue: 0.9358181424, alpha: 1),
              selectionColor: #colorLiteral(red: 0.9185850158, green: 0.9680099289, blue: 0.9050487743, alpha: 1),
              statusBarStyle: .default
        ),
        Theme(name: "Yo",
              primaryTextColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
              secondaryTextColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
              backgroundColor: #colorLiteral(red: 0.7613530623, green: 0.5654633377, blue: 0.8339512017, alpha: 1),
              buttonColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
              barColor: #colorLiteral(red: 0.6854329427, green: 0.296851703, blue: 0.7056018306, alpha: 1),
              barTextColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
              increaseColor: #colorLiteral(red: 0.5908448861, green: 0.9132215712, blue: 0.69664171, alpha: 1),
              increaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              decreaseColor: #colorLiteral(red: 1, green: 0.03500210629, blue: 0.4759685841, alpha: 1),
              decreaseTextColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
              settingsBackgroundColor: #colorLiteral(red: 0.8693273206, green: 0.7664627374, blue: 0.8716634115, alpha: 1),
              selectionColor: #colorLiteral(red: 1, green: 0.263262103, blue: 1, alpha: 1),
              statusBarStyle: .lightContent
        ),
    ]
    
    static var current: Theme = themes[UserSettings.themeIndex]
    
    static var themeables = [Themeable]()
}

