//
//  CalorieIntakeViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/9/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import CircularSlider
import Alamofire

class CalorieIntakeViewController: UIViewController,CircularSliderDelegate {
    
    var datePicked : Date?
    var calorieIntakeValue : String?
    
    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet var datePicker : UIDatePicker!
    
    var healthManager = HealthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Food Consumption"
        
        var image1 = UIImage(named: "time.png")
        
        image1 = image1?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image1, style: UIBarButtonItemStyle.done, target: self, action: #selector(CalorieIntakeViewController.chooseReadingTIme))
        
        
        var image2 = UIImage(named: "upload.png")
        
        image2 = image2?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.done, target: self, action: #selector(CalorieIntakeViewController.saveCalorieIntake))

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
    
    @IBAction func saveCalorieIntake(){
        self.saveCalorieIntakeToserver()
    }
    
    func saveCalorieIntakeToserver() {
        if self.datePicked == nil {
            self.showAlert("Date Missing.", message: "Please provide the time for the record")
            return
        }
        
        let workOutCalorieBurned : Parameters = ["patientId" : 111,"unit" : "calorie", "ObservationDate": self.datePicked?.iso8601 , "caloriesBurned": self.calorieIntakeValue]
        Alamofire.request("http://172.20.10.8:9000/patient/caloriesIntake", method: .post, parameters: workOutCalorieBurned, encoding: JSONEncoding.default).response { (response) in
            print(response)
            self.showAlert("Successful", message: "Record Saved")
        }
    }
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        self.calorieIntakeValue = "\(floorf(value))"
        return floorf(value)
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
