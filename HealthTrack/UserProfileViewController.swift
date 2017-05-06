//
//  UserProfileViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/11/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var metricNames = [ "Age", "Gender", "Blood Group", "Weight(Kg)", "Height", "Blood Pressure"];
    var currentTextField : UITextField?
    var feet = [0,1,2,3,4,5,6,7,8,9,10];
    var inches = [0,1,2,3,4,5,6,7,8,9,10,11,12]
    
    var heighInMeters : Double = 0
    var hString = ""
    var fString = ""
    
    var heightInMeter : Double = 0
    var weightInKgs : Double = 0
    var bloodPressure : Double = 0
    
    var isHeightPickerView : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
       
        
        cell.metricValue.tag = indexPath.row
        cell.metricValue.placeholder = self.metricNames[indexPath.row]
        
        if indexPath.row == 0 {
            cell.metricValue?.text = "\(User.sharedInstance.age!)"
            
        }else if indexPath.row == 1 {
            cell.metricValue?.text = "\(User.sharedInstance.biologicalSex!)"
            
        }else if indexPath.row == 2{
            cell.metricValue?.text = "\(User.sharedInstance.bloodType!)"
            
        }
        else if indexPath.row == 3{
            
        }else if indexPath.row == 4{
            
        }
        
        return cell;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.currentTextField = textField;
        
        if textField.tag == 3 || textField.tag == 5 {
            
            self.isHeightPickerView = false
            
            textField.keyboardType = UIKeyboardType.numberPad

        }
        
        if textField.tag == 4{
            
            self.isHeightPickerView = true
            
            let hPicker = UIPickerView()
            hPicker.delegate = self;
            hPicker.dataSource = self;
            hPicker.delegate?.pickerView!(hPicker, didSelectRow: 0, inComponent: 0)
            
            
            textField.inputView = hPicker
        }
        
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 3 {
            
            if textField.text != nil && !(textField.text?.isEmpty)!{
                self.weightInKgs = Double(textField.text!)!

            }
            
        }
        if textField.tag == 5 {
            
            if textField.text != nil && !(textField.text?.isEmpty)!{
                self.bloodPressure = Double(textField.text!)!
                
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if self.isHeightPickerView {
            return 4
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if self.isHeightPickerView {
            if component == 0{
                return feet.count

            }
            if component == 1{
                return 1
   
            }
            if component == 2 {
            return self.inches.count
            }
            if component == 3 {
                return 1
            }
        } else {
            if component == 0 {
                return 150
            }
            if component == 1 {
                return 1
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if self.isHeightPickerView {
            if component == 0{
                return "\(feet[row])"
                
            }
            if component == 1{
                return "feet"
                
            }
            if component == 2 {
                return "\(inches[row])"
            }
            if component == 3 {
                return "inches"
            }
        } else {
            if component == 0 {
                return "\(row+1)"
            }
            if component == 1 {
                return "Kg"
            }
        }
        return ""
    }
    
    var currentFeet : Double = 0
    var CurrentInches : Double = 0
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if component == 0 {
            hString =   "\(row)" + "  ft  "
            self.currentFeet = Double(row)
        }
        if component == 2 {
            fString =  "\(row)" + "  inches"
            self.CurrentInches = Double(row)
        }
        
        self.currentTextField?.text = hString + fString
        
        self.heighInMeters = self.heightInMeters(feet: self.currentFeet, inches: self.CurrentInches)
        
    }
    
    func heightInMeters(feet : Double, inches : Double) -> Double {
        
        var Convertedfeet = inches/12
        var totalFeet = feet + Convertedfeet
        
        var meters = totalFeet/3.2808
        return meters
    }
    
    @IBAction func dismissUserProfile() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUserProfileToServer() {
        
        if self.currentTextField != nil {
            self.currentTextField?.resignFirstResponder()
        }
        
        var bmi = self.weightInKgs / (self.heighInMeters * self.heighInMeters)
        
    }
}
