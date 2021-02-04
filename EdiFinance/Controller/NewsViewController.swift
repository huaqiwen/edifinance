//
//  NewsViewController.swift
//  EdiFinance
//
//  Created by Peter Ke on 2018-05-28.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    var displayingNews: [News] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var passingUrl: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserSettings.displayCompactNews = true
        
//        edgesForExtendedLayout = [.left, .right, .bottom]
//        self.presentingViewController?.view.backgroundColor = UIColor.white
        
        DataService.fetchStockNews(symbols: UserSettings.savedSymbols) { (news) in
            guard let news = news else { return }
            self.displayingNews = DataService.combineNews(news)
        }
        
        self.tableView.es.addPullToRefresh {
            print("Pull to refresh activated")
            DataService.fetchStockNews(symbols: UserSettings.savedSymbols, completion: { (news) in
                print("Done fetching news")
                self.tableView.es.stopPullToRefresh()
                guard let news = news else { return }
                self.displayingNews = DataService.combineNews(news)
            })
        }
        
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NewDetailViewController {
            destination.urlStr = passingUrl
        }
    }

}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayingNews.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = displayingNews[indexPath.row]
        // compact
        if UserSettings.displayCompactNews || news.summary == "No summary available." {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "compactCell", for: indexPath) as? NewsCompactTableViewCell else { return UITableViewCell() }
            
            cell.headlineLabel.text = news.headLine
            cell.sourceLabel.text = news.source
            cell.timeLabel.text = news.date.toIntervalString()
            
            let theme = Theme.current
            cell.headlineLabel.textColor = theme.primaryTextColor
            cell.sourceLabel.textColor = theme.secondaryTextColor
            cell.timeLabel.textColor = theme.secondaryTextColor
            cell.backgroundColor = theme.backgroundColor
            
            return cell
        }
        // normal
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewsTableViewCell
            else { return UITableViewCell() }
        
        cell.headlineLabel.text = news.headLine
        cell.summaryLabel.text = news.summary
        
        // replaces all multiple spaces with a single space
        let regex = try! NSRegularExpression(pattern: "\\s+", options: [])
        let range = NSMakeRange(0, news.summary.count)
        var formattedSummary = regex.stringByReplacingMatches(in: news.summary, options: [], range: range, withTemplate: " ")
        // remove space if it is the first character
        if formattedSummary[formattedSummary.startIndex] == " " {
            formattedSummary.remove(at: formattedSummary.startIndex)
        }
        cell.summaryLabel.text = formattedSummary
        
        cell.sourceLabel.text = news.source
        cell.timeLabel.text = news.date.toIntervalString()
        
        let theme = Theme.current
        cell.headlineLabel.textColor = theme.primaryTextColor
        cell.summaryLabel.textColor = theme.primaryTextColor
        cell.sourceLabel.textColor = theme.secondaryTextColor
        cell.timeLabel.textColor = theme.secondaryTextColor
        cell.backgroundColor = theme.backgroundColor
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = theme.selectionColor
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UserSettings.displayCompactNews || displayingNews[indexPath.row].summary == "No summary available." {
            return 88
        } else {
            return 160
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        passingUrl = displayingNews[indexPath.row].url
        self.performSegue(withIdentifier: "showNewsDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewsViewController: Themeable {
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        navigationController?.navigationBar.barTintColor = theme.barColor
        navigationController?.navigationBar.tintColor = theme.buttonColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: theme.barTextColor
        ]
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.selectionColor
        tableView.reloadData()
    }
}


