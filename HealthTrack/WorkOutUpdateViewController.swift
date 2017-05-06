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
        self.title = "Workout"
        
        var image1 = UIImage(named: "time.png")
        
        image1 = image1?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image1, style: UIBarButtonItemStyle.done, target: self, action: #selector(WorkOutUpdateViewController.chooseReadingTIme))
        
        
        var image2 = UIImage(named: "upload.png")
        
        image2 = image2?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.done, target: self, action: #selector(WorkOutUpdateViewController.saveWorkout))

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
    
    @IBAction func saveWorkout(){
        self.saveWorkoutToserver()
    }
    
    func saveWorkoutToserver() {
        
        if self.datePicked == nil {
            self.showAlert("Date Missing.", message: "Please provide the time for the record")
            return
        }
        
        let workOutCalorieBurned : Parameters = ["patientId" : 111,"unit" : "calorie", "ObservationDate": self.datePicked?.iso8601  , "CalorieBurned": self.workOutCalorieBurned!]
        let url = SERVER_PATH + "patient/caloriesBurned"

        
        Alamofire.request(url, method: .post, parameters: workOutCalorieBurned, encoding: JSONEncoding.default).response { (response) in
            print(response)
            self.showAlert("Successful", message: "Record Saved")
        }
    }
    
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        self.workOutCalorieBurned = "\(floorf(value))"
        return floorf(value)
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
