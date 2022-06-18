//
//  HodlPieChartView.swift
//  hodl
//
//  Created by Emmanuel Adigun on 2022/06/09.
//

import UIKit
import Charts

class HodlPieChartView: PieChartView {
    private let captionLocal   = UILabel( "BTC\(globalLocalCurrency)", .left, 12, .medium, .lightGray)
    private let portfolioText  = UILabel( "Portfolio", .center, 18, .bold, .white)
    private let leftValue      = UILabel( "0.0", .left, 12, .medium, .white)
    private let rightValue     = UILabel( "0.0", .left, 12, .medium, .white)
    private let topText        = UILabel( "Total", .center, 14, .medium, .white)
    private let totalValue     = UILabel( "0.00", .center, 18, .bold, .white)
    private let bottomText     = UILabel( "", .center, 12, .regular, .lightGray)
    private var pieChartColors = [UIColor(rgbHexValue: 0x003f5c),UIColor(rgbHexValue: 0xde425b),.mediumSeaGreenColor,UIColor(rgbHexValue: 0xffa600),UIColor(rgbHexValue: 0x58508d)]
    
    private var localFiat: String?
    private var entries: [PieChartDataEntry] = [PieChartDataEntry(value: 1.0, label: "")]
    
    private var previousTotal = Float(0.0)
    
    convenience init(localFiat: String = "ZAR") {
        self.init(frame: .zero)
        self.localFiat = localFiat
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 400.0).isActive = true
        
        createViews()
        initChart()
        registerNotifications()
    }

    private func initChart() {
        self.usePercentValuesEnabled = true
        self.drawSlicesUnderHoleEnabled = false
        self.holeColor = .clear
        self.holeRadiusPercent = 0.60
        self.transparentCircleRadiusPercent = 0.61
        self.chartDescription?.enabled = false
        self.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        self.drawHoleEnabled = true
        self.rotationAngle = 0
        self.rotationEnabled = true
        self.highlightPerTapEnabled = true
        self.legend.enabled = false
        self.backgroundColor = .clear
        
        let set = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0, label: "")], label: "Exchanges")
        set.drawIconsEnabled = false
        set.sliceSpace = 3
        set.colors = pieChartColors
        
        let data = PieChartData(dataSet: set)
        data.setValueFormatter(HodlDefaultValueFormatter())
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.white)
        
        self.data = data
        self.highlightValues(nil)
        
    }
    
    private func createViews() {
        let left = createLeftView()
        self.addSubview(left)
        left.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        left.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5.0).isActive = true
        
        self.addSubview(portfolioText)
        portfolioText.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        portfolioText.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        let right = createRightView()
        self.addSubview(right)
        right.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        right.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5.0).isActive = true
        
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        v.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        v.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        v.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.50).isActive = true
        
        v.addSubview(topText)
        v.addSubview(totalValue)
        v.addSubview(bottomText)
        
        totalValue.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        totalValue.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        
        topText.topAnchor.constraint(equalTo: totalValue.topAnchor, constant: -18.0).isActive = true
        topText.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        
        bottomText.topAnchor.constraint(equalTo: totalValue.bottomAnchor, constant: 2.0).isActive = true
        bottomText.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
    }
    
    
    
    private func createLeftView() -> UIView {
        let v = UIView(60)
        let caption = UILabel( "BTCUSD", .left, 12, .medium, .lightGray)
        v.addSubview(caption)
        v.addSubview(leftValue)
        
        caption.topAnchor.constraint(equalTo:   v.topAnchor, constant: 5.0).isActive = true
        caption.leftAnchor.constraint(equalTo:  v.leftAnchor, constant: 5.0).isActive = true
        leftValue.topAnchor.constraint(equalTo:  caption.bottomAnchor, constant: 5.0).isActive = true
        leftValue.leftAnchor.constraint(equalTo: v.leftAnchor, constant: 5.0).isActive = true
        
        return v
    }
    
    private func createRightView() -> UIView {
        let v = UIView(60)
        let caption = self.captionLocal //UILabel( "BTC\(self.localFiat!)", .left, 12, .medium, .lightGray)
        v.addSubview(caption)
        v.addSubview(rightValue)
        
        caption.topAnchor.constraint(equalTo:   v.topAnchor, constant: 5.0).isActive = true
        caption.trailingAnchor.constraint(equalTo:  v.trailingAnchor, constant: -5.0).isActive = true
        rightValue.topAnchor.constraint(equalTo:  caption.bottomAnchor, constant: 5.0).isActive = true
        rightValue.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -5.0).isActive = true
        
        return v
    }
    
    
    private func registerNotifications() {
        self.localFiat = globalLocalCurrency
        NotificationCenter.default.addObserver(forName: .refreshExchangeDataTotals, object: nil, queue: nil) { [weak self] (notification) in
            guard let this = self , let localFiat = this.localFiat else { return }
            DispatchQueue.main.async {
                if let data = notification.userInfo as? [String:Float] {
                    this.totalValue.text = "\(localFiat) " + "\(data["localtotal"]!)".toCurrency
                    this.bottomText.text =  String(format: "%.2f", data["btctotal"]!) + " BTC"
                    this.leftValue.text  = "\(data["btcUSD"]!)".toCurrency
                    this.rightValue.text = "\(data["btcLocal"]!)".toCurrency
                    
                    let p = data["localtotal"]!
                    if p > this.previousTotal { this.totalValue.textColor = .mediumSeaGreenColor}
                    else { this.totalValue.textColor = .defaultAppStrongColor }
                    this.previousTotal   = data["localtotal"]!
                    
                    this.captionLocal.text = "BTC\(globalLocalCurrency)"
                }
                
                if let exchanges = notification.object as? [String:Float], let data = this.data {
                    let m = exchanges.map({$0.value}).reduce(0,+)
                    if m > 0 {
                        data.dataSets[0].clear()
                        data.dataSets[0].resetColors()
                        var i = 0
                        for exchange in exchanges.sorted(by: {$0.value > $1.value}) {
                            if  Double(exchange.value) > 0 {
                                let entry = PieChartDataEntry(value: Double(exchange.value), label: exchange.key)
                                data.dataSets[0].addColor(this.pieChartColors[i] )
                                _ = data.dataSets[0].addEntry(entry)
                                i += 1
                            }
                        }
                        this.notifyDataSetChanged()
                    }
                }
            }
        }
    }
    
}


class HodlDefaultValueFormatter: DefaultValueFormatter {
    override func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let label = (entry as! PieChartDataEntry).label , label.isEmpty { return "" }
        return super.stringForValue(value, entry: entry, dataSetIndex: dataSetIndex, viewPortHandler: viewPortHandler) + "%"
    }
}
