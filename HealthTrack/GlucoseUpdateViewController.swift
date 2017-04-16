//
//  GlucoseUpdateViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/16/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit

class GlucoseUpdateViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var pickerView : UIPickerView!
    @IBOutlet var textArea : UITextField!
    
    var prePostString : String?
    var MealType : String?
//    var timings = ["Pre", "Post"];
//    var sections = ["Breakfast", "Lunch", "Dinner","Snacks" ];
    
    var datePicked : Date?
    var currentGlucoseValue : String?
    
    @IBOutlet var datePicker : UIDatePicker!
    
    var healthManager = HealthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Glucose Update"
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        datePicker.addTarget(self, action: #selector(ActivityViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
          return 2
        } else {
           return 4
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if component == 0 {
//            return timings[row]
//        } else {
//            return sections[row]
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 0 {
//           self.prePostString = self.timings[row]
//        }else {
//            self.MealType = self.sections[row]
//        }
//        self.pickerView.isHidden = true
//    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textArea = textField;
        
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textArea.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.currentGlucoseValue = textField.text
    }
    
    @IBAction func chooseReadingTIme() {
        self.datePicker.isHidden = false
//        self.pickerView.isHidden = false
    }
    
    func datePickerChanged(datePicker:UIDatePicker){
        
        self.datePicked = datePicker.date
        self.datePicker.isHidden = true
    }
    
    @IBAction func saveGlucoseValue(){
        
        self.textArea.resignFirstResponder()
        
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
            }
        })
    }
    
}
