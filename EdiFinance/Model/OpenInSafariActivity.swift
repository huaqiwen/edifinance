//
//  OpenInSafariActivity.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-29.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class OpenInSafariActivity: UIActivity {

    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "TestACtionss.Safari")
    }
    
    override var activityTitle: String? {
        return "Open in Safari"
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        
    }
    
    override var activityViewController: UIViewController? {
        return nil
    }
    
    override func perform() {
        UIApplication.shared.open(gurl, options: [:]) { (status) in }
        
        self.activityDidFinish(true)
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "Safari")
    }
    
}
