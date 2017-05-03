//
//  WorkOutUpdateViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/24/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import  CircularSlider
import Alamofire


class WorkOutUpdateViewController: UIViewController,CircularSliderDelegate {

    
    var datePicked : Date?
    var workOutCalorieBurned : String?
    
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
    
    @IBAction func saveWorkout(){
        self.saveWorkoutToserver()
    }
    
    func saveWorkoutToserver() {
        let workOutCalorieBurned : Parameters = ["patientId" : 111,"unit" : "calorie", "ObservationDate": self.datePicked?.iso8601  , "CalorieBurned": self.workOutCalorieBurned!]
        let url = SERVER_PATH + "patient/caloriesBurned"

        
        Alamofire.request(url, method: .post, parameters: workOutCalorieBurned, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
        }
    }
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        self.workOutCalorieBurned = "\(floorf(value))"
        return floorf(value)
    }
}
