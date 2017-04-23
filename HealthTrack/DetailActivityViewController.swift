//
//  DetailActivityViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/14/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit

enum SampleType {
    case RunningType
    case StepCountType
    case GlucoseType
}

class DetailActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var detailActivitySamples = [HKQuantitySample]()
    var currentDetailSampelType : SampleType = .RunningType
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailActivitySamples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailActivityCell = tableView.dequeueReusableCell(withIdentifier: "DetailActivityCell") as! DetailActivityCell
        
        let CurrentIndexSample = self.detailActivitySamples[indexPath.row] as HKQuantitySample
        
        var dateFormatter = DateFormatter()
        
        if self.currentDetailSampelType == .RunningType{
            detailActivityCell.sampleTypeLabel.text = "Running and Walking"
            detailActivityCell.sampleValueLabel.text = "\(CurrentIndexSample.quantity.doubleValue(for: HKUnit.mile()))"
            detailActivityCell.sampleDateLabel.text = dateFormatter.stringFromDate(date: CurrentIndexSample.startDate)
            
        }else if self.currentDetailSampelType == .StepCountType {
            
            detailActivityCell.sampleTypeLabel.text = "Step Count"
            detailActivityCell.sampleValueLabel.text = "\(CurrentIndexSample.quantity.doubleValue(for: HKUnit.count()))"
            detailActivityCell.sampleDateLabel.text = dateFormatter.stringFromDate(date: CurrentIndexSample.startDate)
            
        }else if self.currentDetailSampelType == .GlucoseType {
            
            let gramUnit = HKUnit.gram()
            let volumeUnit = HKUnit.literUnit(with: .deci)
            let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
            
            
            detailActivityCell.sampleTypeLabel.text = "Gluose Level"
            detailActivityCell.sampleValueLabel.text = "\(CurrentIndexSample.quantity.doubleValue(for: glucoseUnit))"
            detailActivityCell.sampleDateLabel.text = dateFormatter.stringFromDate(date: CurrentIndexSample.startDate)
        }
        
        return detailActivityCell
    }
 
}
