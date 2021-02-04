//
//  DetailViewController.swift
//  EdiFinance
//
//  Created by Eric Hua on 2018-05-06.
//  Copyright © 2018 QiwenHua. All rights reserved.
//

import UIKit
import Charts
import FontAwesome

class DetailViewController: UIViewController {
    
    var displayingQuote: StockQuote?
    var displayingSymbol: String = ""
    var displayingRange: ChartRange = .d1
    var displayingChart: StockChart?
    
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var changePerLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 34.0
        tableView.allowsSelection = false
        
        
        // Init Chart View
        chartView.delegate = self
        setupChart()
        
        
        // Init basic information
        symbolLabel.text = displayingQuote?.symbol
        priceLabel.text = String(displayingQuote!.latestPrice)
        changeLabel.text = String(displayingQuote!.change)
        changeLabel.textColor = displayingQuote!.change >= 0 ? greenColor : redColor
        changePerLabel.text = String(displayingQuote!.changePercent * 100) + "%"
        changePerLabel.textColor = displayingQuote!.changePercent >= 0 ? greenColor : redColor
        starButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        if UserSettings.savedSymbols.contains(displayingSymbol) {
            starButton.setTitle(String.fontAwesomeIcon(name: .star), for: .normal)
        } else {
            starButton.setTitle(String.fontAwesomeIcon(name: .starO), for: .normal)
        }
        
        // basically init chart data
        chartRangeChanged()
        
        
        applyTheme(theme: Theme.current)
        Theme.themeables.append(self)
    }
    
    func chartRangeChanged() {
        // clear currently displaying data
        chartView.clear()
        
        chartView.noDataText = "Loading data..."
        DataService.fetchStockChart(symbol: displayingSymbol, range: displayingRange) { (chart) in
            if let chart = chart {
                // loads the chart and saves it locally
                RealmService.updateStockChart(chart, completion: nil)
                self.updateChartView(chart: chart)
            } else if let local = RealmService.getStockChart(symbol: self.displayingSymbol, range: self.displayingRange.rawValue) {
                // cannot fetch from API, so load local
                print("Loaded stock locally")
                self.updateChartView(chart: local)
            } else {
                // local does not exist either
                self.chartView.noDataText = "Data is unavailable. Please check your internet connection."
            }
        }
    }
    
    func updateChartView(chart: StockChart) {
        displayingChart = chart
        setupChart()
        chartView.data = LineChartData(dataSet: chart.lineChartDataSet())
    }
    
    func setupChart() {
        chartView.chartDescription?.enabled = false
        
        // drag/zoom
        chartView.dragXEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        
        // Legend
        chartView.legend.enabled = false
        
        // Axis
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.setLabelCount(3, force: false)
        
        
        
        // axis formatter - converts values into dates on axis
        if let chart = displayingChart {
            chartView.xAxis.valueFormatter = DateAxisFormatter(chart: chart)
        } else {
            chartView.xAxis.valueFormatter = nil
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func starButtonClicked(_ sender: UIButton) {
        if let index = UserSettings.savedSymbols.index(of: displayingSymbol) {
            UserSettings.savedSymbols.remove(at: index)
            starButton.setTitle(String.fontAwesomeIcon(name: .starO), for: .normal)
        } else {
            UserSettings.savedSymbols.append(displayingSymbol)
            starButton.setTitle(String.fontAwesomeIcon(name: .star), for: .normal)
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            displayingRange = .d1
        case 1:
            displayingRange = .d5
        case 2:
            displayingRange = .m1
        case 3: 
            displayingRange = .m6
        case 4:
            displayingRange = .y1
        case 5:
            displayingRange = .y5
        default:
            break
        }
        chartRangeChanged()
    }
}

extension DetailViewController: ChartViewDelegate {
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailTableViewCell
        switch indexPath.row {
        case 0:
            cell.title.text = "Open"
            cell.value.text = self.displayingQuote!.open == -69 ? "-" : String(self.displayingQuote!.open)
        case 1:
            cell.title.text = "Open Time"
            cell.value.text = self.displayingQuote!.openTime == -69 ? "-" : Date(timeIntervalSince1970: self.displayingQuote!.openTime / 1000).toString(format: "MM-dd-yyyy HH:mm")
        case 2:
            cell.title.text = "Close"
            cell.value.text = self.displayingQuote!.close == -69 ? "-" : String(self.displayingQuote!.close)
        case 3:
            cell.title.text = "Close Time"
            cell.value.text = self.displayingQuote!.closeTime == -69 ? "-" : Date(timeIntervalSince1970: self.displayingQuote!.closeTime / 1000).toString(format: "MM-dd-yyyy HH:mm")
        case 4:
            cell.title.text = "High"
            cell.value.text = self.displayingQuote!.high == -69 ? "-" : String(self.displayingQuote!.high)
        case 5:
            cell.title.text = "Low"
            cell.value.text = self.displayingQuote!.low == -69 ? "-" : String(self.displayingQuote!.low)
        case 6:
            cell.title.text = "Latest Price"
            cell.value.text = self.displayingQuote!.latestPrice == -69 ? "-" : String(self.displayingQuote!.latestPrice)
        case 7:
            cell.title.text = "Latest Volume"
            cell.value.text = self.displayingQuote!.latestVolume == -69 ? "-" : String(DataService.roundLargeDouble(number: self.displayingQuote!.latestUpdate))
        case 8:
            cell.title.text = "Previous Close"
            cell.value.text = self.displayingQuote!.previousClose == -69 ? "-" : String(self.displayingQuote!.previousClose)
        case 9:
            cell.title.text = "Change"
            cell.value.text = self.displayingQuote!.change == -69 ? "-" : String(self.displayingQuote!.change)
        case 10:
            cell.title.text = "Change Percent"
            cell.value.text = self.displayingQuote!.changePercent == -69 ? "-" : String(self.displayingQuote!.changePercent)
        case 11:
            cell.title.text = "Average Volume"
            cell.value.text = self.displayingQuote!.avgTotalVolume == -69 ? "-" : String(DataService.roundLargeDouble(number: self.displayingQuote!.avgTotalVolume))
        case 12:
            cell.title.text = "Market Cap"
            cell.value.text = self.displayingQuote!.marketCap == -69 ? "-" : String(DataService.roundLargeDouble(number: self.displayingQuote!.marketCap))
        case 13:
            cell.title.text = "P/E Ratio"
            cell.value.text = self.displayingQuote!.peRatio == -69 ? "-" : String(self.displayingQuote!.peRatio)
        case 14:
            cell.title.text = "52 Weeks High"
            cell.value.text = self.displayingQuote!.week52High == -69 ? "-" : String(self.displayingQuote!.week52High)
        case 15:
            cell.title.text = "52 Weeks Low"
            cell.value.text = self.displayingQuote!.week52Low == -69 ? "-" : String(self.displayingQuote!.week52Low)
        default:
            break
        }
        
        let theme = Theme.current
        cell.title.textColor = theme.primaryTextColor
        cell.value.textColor = theme.primaryTextColor
        cell.backgroundColor = theme.backgroundColor
        
        return cell
    }
}

extension DetailViewController: Themeable {
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        
        symbolLabel.textColor = theme.primaryTextColor
        priceLabel.textColor = theme.primaryTextColor
        
        let changeColor = displayingQuote!.change >= 0 ? theme.increaseColor : theme.decreaseColor
        changeLabel.textColor = changeColor
        changePerLabel.textColor = changeColor
        
        segmentedControl.tintColor = theme.buttonColor
        segmentedControl.backgroundColor = UIColor.clear
        
        chartView.xAxis.axisLineColor = theme.primaryTextColor
        chartView.xAxis.labelTextColor = theme.primaryTextColor
        chartView.leftAxis.axisLineColor = theme.primaryTextColor
        chartView.leftAxis.labelTextColor = theme.primaryTextColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.reloadData()
    }
}











