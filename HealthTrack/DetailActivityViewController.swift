//
//  DetailActivityViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/14/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit
import Charts

enum SampleType {
    case RunningType
    case StepCountType
    case GlucoseType
    case CalorieBurned
    case CalorieConsumed
}

class DetailActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var detailActivitySamples = [HKQuantitySample]()
    var currentDetailSampelType : SampleType = .RunningType
//    @IBOutlet weak var barView: BarChartView!
    @IBOutlet weak var barView: LineChartView!

    
    weak var axisFormatDelegate: IAxisValueFormatter?

    override func viewDidLoad() {
        axisFormatDelegate = self
        self.sortData()
        updateChartWithData()
    }
    
    func sortData() {
        self.detailActivitySamples.sort(by: {
        $0.startDate < $1.startDate})
    }
    
//    func updateChartWithData() {
//        var dataEntries: [BarChartDataEntry] = []
//        let chartVAlues = sampleData()
//        let axisData = chartVAlues.axisData
//        let valueData = chartVAlues.valueData
//        for i in 0..<axisData.count {
//            let timeIntervalForDate: TimeInterval = axisData[i].timeIntervalSince1970
//            let dataEntry = BarChartDataEntry(x: Double(i) , y: valueData[i])
//            dataEntries.append(dataEntry)
//        }
//        
//        var chartDataSet : Any?
//        if currentDetailSampelType == .RunningType {
//             chartDataSet = BarChartDataSet(values: dataEntries, label: "Running Data")
//        }else if currentDetailSampelType == .GlucoseType  {
//            chartDataSet = BarChartDataSet(values: dataEntries, label: "Glucose data")
//
//        }else if currentDetailSampelType == .StepCountType {
//            chartDataSet = BarChartDataSet(values: dataEntries, label: "Step count")
//
//        }
//        
//        let chartData = BarChartData(dataSet: chartDataSet as! BarChartDataSet)
//        barView.data = chartData
//        
//        let xaxis = barView.xAxis
//        xaxis.valueFormatter = axisFormatDelegate
//    }
    
    func updateChartWithData() {
        var dataEntries: [ChartDataEntry] = []
        let chartVAlues = sampleData()
        let axisData = chartVAlues.axisData
        let valueData = chartVAlues.valueData
        for i in 0..<axisData.count {
            let timeIntervalForDate: TimeInterval = axisData[i].timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate) , y: valueData[i])
            dataEntries.append(dataEntry)
        }
        
        var chartDataSet : LineChartDataSet?
        if currentDetailSampelType == .RunningType {
            chartDataSet = LineChartDataSet(values: dataEntries, label: "Running Data")
        }else if currentDetailSampelType == .GlucoseType  {
            chartDataSet = LineChartDataSet(values: dataEntries, label: "Glucose data") as LineChartDataSet
            chartDataSet?.circleColors = [NSUIColor.red]
            
        }else if currentDetailSampelType == .StepCountType {
            chartDataSet = LineChartDataSet(values: dataEntries, label: "Step count")
            chartDataSet?.circleColors = [NSUIColor.green]
            
        }
        
        let chartData = LineChartData(dataSet: chartDataSet as! LineChartDataSet)
        barView.data = chartData
        
        let xaxis = barView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        
        barView.animate(xAxisDuration: 2)
    }
    
    func sampleData() -> (axisData : [Date], valueData : [Double]){
        var axisDataArray = [Date]()
        var valuesArray = [Double]()
        
        for aSample in detailActivitySamples {
            
            let workOutSample = aSample
            if currentDetailSampelType == .RunningType {
                valuesArray.append(workOutSample.quantity.doubleValue(for: HKUnit.mile()))
            }
            else if currentDetailSampelType == .StepCountType {
                valuesArray.append(workOutSample.quantity.doubleValue(for: HKUnit.count()))
            }else if currentDetailSampelType == .GlucoseType {
                let gramUnit = HKUnit.gram()
                let volumeUnit = HKUnit.literUnit(with: .deci)
                let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
                
                valuesArray.append(workOutSample.quantity.doubleValue(for: glucoseUnit))

            }
            
            let sampleDate = workOutSample.startDate
            axisDataArray.append(sampleDate)
        }
        return (axisDataArray, valuesArray)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailActivitySamples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailActivityCell = tableView.dequeueReusableCell(withIdentifier: "DetailActivityCell") as! DetailActivityCell
        
        let CurrentIndexSample = self.detailActivitySamples[indexPath.row] as HKQuantitySample
        
        var dateFormatter = DateFormatter()
        
        if self.currentDetailSampelType == .RunningType{
            detailActivityCell.sampleTypeLabel.text = "Running and Walking"
            let twoDecimalPlaces = String(format: "%.2f", CurrentIndexSample.quantity.doubleValue(for: HKUnit.mile()))
            
            detailActivityCell.sampleValueLabel.text = twoDecimalPlaces
            detailActivityCell.sampleDateLabel.text = dateFormatter.timeString(date: CurrentIndexSample.startDate)
            
        }else if self.currentDetailSampelType == .StepCountType {
            
            detailActivityCell.sampleTypeLabel.text = "Step Count"
            let twoDecimalPlaces = String(format: "%.2f", CurrentIndexSample.quantity.doubleValue(for: HKUnit.count()))
            
            detailActivityCell.sampleValueLabel.text = twoDecimalPlaces
            
            detailActivityCell.sampleDateLabel.text = dateFormatter.timeString(date: CurrentIndexSample.startDate)
            
        }else if self.currentDetailSampelType == .GlucoseType {
            
            let gramUnit = HKUnit.gram()
            let volumeUnit = HKUnit.literUnit(with: .deci)
            let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
            
            
            let twoDecimalPlaces = String(format: "%.2f", CurrentIndexSample.quantity.doubleValue(for: glucoseUnit))
            
            detailActivityCell.sampleValueLabel.text = twoDecimalPlaces
            
            detailActivityCell.sampleTypeLabel.text = "Gluose Level"
            detailActivityCell.sampleDateLabel.text = dateFormatter.timeString(date: CurrentIndexSample.startDate)
        }
        
        return detailActivityCell
    }
}

extension DetailActivityViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
