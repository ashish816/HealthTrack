//
//  GlucoseUpdateViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/16/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class GlucoseUpdateViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var pickerView : UIPickerView!
    @IBOutlet var textArea : UITextField!
    
    var prePostString : String?
    var MealType : String?
//    var timings = ["Pre", "Post"];
//    var sections = ["Breakfast", "Lunch", "Dinner","Snacks" ];
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Glucose Update"
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return timings[row]
        } else {
            return sections[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
           self.prePostString = self.timings[row]
        }else {
            self.MealType = self.sections[row]
        }
        self.pickerView.isHidden = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textArea = textField;
        
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textArea.resignFirstResponder()
        return true
    }
    
    @IBAction func chooseReadingTIme() {
        self.pickerView.isHidden = false
    }
    
}
