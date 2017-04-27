//
//  CalorieIntakeViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/9/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import CircularSlider

class CalorieIntakeViewController: UIViewController,CircularSliderDelegate {
    
    var datePicked : Date?
    var calorieIntakeValue : String?
    
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet var datePicker : UIDatePicker!
    
    var healthManager = HealthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCircularSlider()
        
        datePicker.addTarget(self, action: #selector(ActivityViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK: - methods
    fileprivate func setupCircularSlider() {
        circularSlider.delegate = self as! CircularSliderDelegate
    }
    
    @IBAction func chooseReadingTIme() {
        self.datePicker.isHidden = false
    }
    
    func datePickerChanged(datePicker:UIDatePicker){
        
        self.datePicked = datePicker.date
        self.datePicker.isHidden = true
    }
    
    @IBAction func saveCalorieIntake(){
        
        
    }
    
    func saveCalorieIntakeToserver() {
        
    }
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        self.calorieIntakeValue = "\(floorf(value))"
        return floorf(value)
    }
    
}
