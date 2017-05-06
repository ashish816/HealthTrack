//
//  GlucoseUpdateViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/16/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit
import CircularSlider

class GlucoseUpdateViewController: UIViewController,CircularSliderDelegate {
    
    var datePicked : Date?
    var currentGlucoseValue : String?
    
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet var datePicker : UIDatePicker!
    
    var healthManager = HealthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Glucose Update"
        
        var image1 = UIImage(named: "time.png")
        
        image1 = image1?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image1, style: UIBarButtonItemStyle.done, target: self, action: #selector(GlucoseUpdateViewController.chooseReadingTIme))
        
        
        var image2 = UIImage(named: "upload.png")
        
        image2 = image2?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.done, target: self, action: #selector(GlucoseUpdateViewController.saveGlucoseValue))
        
//        self.datePicker.setValue(UIColor.white, forKey: "textColor")
        setupCircularSlider()

        datePicker.addTarget(self, action: #selector(ActivityViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK: - methods
    fileprivate func setupCircularSlider() {
        circularSlider.delegate = self as! CircularSliderDelegate
    }
    
    @IBAction func chooseReadingTIme() {
        self.datePicker.isHidden = !self.datePicker.isHidden
    }
    
    func datePickerChanged(datePicker:UIDatePicker){
        
        self.datePicked = datePicker.date
    }
    
    @IBAction func saveGlucoseValue(){
        
        if self.datePicked == nil {
            self.showAlert("Date Missing.", message: "Please provide the time for the record")
            return
        }
        let glucoseVale = Double(self.currentGlucoseValue!)
        self.saveGlucoseSample(glucose: glucoseVale!,date: self.datePicked!)
    }
    
    func saveGlucoseSample(glucose:Double, date:Date ) {
        // 1. Create a BMI Sample
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
        
        let gramUnit = HKUnit.gram()
        let volumeUnit = HKUnit.literUnit(with: .deci)
        let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
        
        let glucoseQuantity = HKQuantity(unit: glucoseUnit, doubleValue: glucose)
        
        let glucoseSample = HKQuantitySample(type: glucoseType!, quantity: glucoseQuantity, start: date, end: date)
        // 2. Save the sample in the store
        healthManager.healthKitStore.save(glucoseSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                print("Error saving BMI sample: \(error?.localizedDescription)")
            } else {
                
                print("Glucose sample saved successfully!")
                self.showAlert("Successful", message: "Record Saved")

            }
        })
    }
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        self.currentGlucoseValue = "\(floorf(value))"
        return floorf(value)
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

