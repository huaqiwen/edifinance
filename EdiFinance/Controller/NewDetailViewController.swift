//
//  NewDetailViewController.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-29.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit
import WebKit
import FontAwesome

var gurl: URL = URL(string: "http://www.google.com")!

class NewDetailViewController: UIViewController{

    @IBOutlet weak var webView: WKWebView!
//    @IBOutlet weak var shareButton: UIButton!
    
    var urlStr: String = ""
    var progBar = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        navigationItem.rightBarButtonItem = shareButton
        
        gurl = URL(string: urlStr)!
        let request = URLRequest(url: gurl)
        webView.load(request)
        
        progBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        progBar.progress = 0.0
        progBar.tintColor = UIColor.orange
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        webView.addSubview(progBar)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progBar.alpha = 1.0
            progBar.setProgress(Float(webView.estimatedProgress), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: { 
                    self.progBar.alpha = 0.0
                }) { (finished: Bool) in
                    self.progBar.progress = 0.0
                }
            }
        }
    }
    
    // 释放observer
    override func viewDidDisappear(_ animated: Bool) {
        if webView.observationInfo != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func shareButtonPressed() {
        let activityVC = UIActivityViewController(activityItems: [URL(string: urlStr)!], applicationActivities: [OpenInSafariActivity()])
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}





