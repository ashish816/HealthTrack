//
//  ActivityViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/11/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit
import CVCalendar
import Alamofire

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let healthManager = HealthManager()
    var walkingAvg : Double = 0.0;
    var totalEnergyBurned: Double = 0;
    var totalStepCount : Double = 0.0;
    var glucoseAverage: Double = 0.0;
    
    @IBOutlet var activityTableView : UITableView!
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var datePickerButton : UIButton!
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
        
    var datePicked : Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authorizeHealthkit();
        
        self.title = "Activity"
        datePicker.addTarget(self, action: #selector(ActivityViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        

        var image = UIImage(named: "User.png")
        
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.done, target: self, action: #selector(ActivityViewController.openProfilePage))
        
        // Do any additional setup after loading the view.
    }
    
    func authorizeHealthkit() {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }
    
    
    func datePickerChanged(datePicker:UIDatePicker){
        
        self.datePicked = datePicker.date
        self.getTotalRunningData(forDate: self.datePicked!)
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
//        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
//        let cal = NSCalendar.currentCalendar()
//        comp = cal.components([.Era, .Day, .Month, .Year, .Hour, .Minute] , fromDate: datePicker.date)
//        
//        // getting day, month, year ect
//        print ("Era:\(comp.era) Date:\(comp.day) Month:\(comp.month) Month:\(comp.year) Hours: \(comp.hour) Minuts:\(comp.minute)")
        
        self.datePicker.isHidden = true
    }
    
    func getTotalRunningData(forDate: Date){
        healthManager.readRunningWorkOuts(forDate: forDate,{ (results, error) -> Void in
            if( error != nil )
            {
                print("Error reading workouts: \(error?.localizedDescription)")
                return;
            }
            else
            {
                var totalWalingForTheDay : Double=0.0;
                
                for aSample in results! {
                    
                    let workOutSample = aSample as! HKQuantitySample
                    
                    totalWalingForTheDay += workOutSample.quantity.doubleValue(for: HKUnit.mile())
                }
                
                self.walkingAvg = totalWalingForTheDay
                self.getToatalStepCount(forDate: forDate)

            }
            
        })
    }
    
    func getToatalStepCount(forDate: Date) {
        healthManager.readStepCount(forDate: forDate, { (results, error) -> Void in
            if( error != nil )
            {
                print("Error reading workouts: \(error?.localizedDescription)")
                return;
            }
            else
            {
                
                var currentStepCount : Double = 0.0;
                
                for aSample in results! {
                    currentStepCount += aSample.quantity.doubleValue(for: HKUnit.count())
                }
                
                self.totalStepCount = currentStepCount
                self.getGlucoseData(forDate: forDate)

            }
            
            //Kkeep workouts and refresh tableview in main thread
            
        })
    }
    
    func getTotalCalorieBurned(forDate: Date) {
        healthManager.readCalorieBurned(forDate: self.datePicked, { (results, error) -> Void in
            if( error != nil )
            {
                print("Error reading workouts: \(error?.localizedDescription)")
                return;
            }
            else
            {
                for aSample in results! {
                    self.totalEnergyBurned += aSample.quantity.doubleValue(for: HKUnit.joule())
                }
                
            }
            
        })
    }
    
    @IBAction func syncDataToServer() {
//        let parameters : Parameters = ["patientId" : 111, "name" : "ashish Mishra" , "age" : 28]
        
        var dateFormatter = DateFormatter()
        
        let activityData : Dictionary = ["Walking" : self.walkingAvg, "stepcount" : self.totalStepCount, "Date": dateFormatter.stringFromDate(date: self.datePicked!)] as [String : Any];
        
        
        let parameters : Parameters = ["patientId" : 222, "name" : "ashish Mishra" , "age" : 28, "Activity" : activityData]
        
        Alamofire.request("http://10.250.216.12:9000/patient/activites", method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            print(response)
        }
    }
    
    @IBAction func openDatePicker(id : UIButton) {
        self.datePicker.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.activityTableView.reloadData()
    }
    
    func openProfilePage() {
        
        self.performSegue(withIdentifier: "ToUserProfile", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! UserProfileViewController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Today"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityVCCell", for: indexPath) as! ActivityTrackCell
        
        cell.layer.cornerRadius = 15;
        
        if indexPath.row == 0 {
            cell.activityTypeLabel?.text = "WalkingRunningDistance";
            cell.activityTypleValue?.text = "\(self.walkingAvg)"
        }else if indexPath.row == 1{
            cell.activityTypeLabel?.text = "StepCount";
            cell.activityTypleValue?.text = "\(self.totalStepCount)"
        }else if indexPath.row == 2{
            cell.activityTypeLabel?.text = "CaloriesBurned";
            cell.activityTypleValue?.text = "\(self.totalEnergyBurned)"
            
        }else if indexPath.row == 3{
            cell.activityTypeLabel?.text = "GlucoseAverage";
            cell.activityTypleValue?.text = "\(self.glucoseAverage)"
        }
        return cell;
    }
    
    func getGlucoseData(forDate: Date) {
        healthManager.readGlucoseSamples(forDate: forDate, { (results, error) -> Void in
            if( error != nil )
            {
                print("Error reading workouts: \(error?.localizedDescription)")
                return;
            }
            else
            {
                
                var glucoseSamples : Double = 0.0;
                
                let gramUnit = HKUnit.gram()
                let volumeUnit = HKUnit.literUnit(with: .deci)
                let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
                
                for aSample in results! {
                    glucoseSamples += aSample.quantity.doubleValue(for: glucoseUnit)
                }
                
                self.glucoseAverage = glucoseSamples/Double((results?.count)!)
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.activityTableView.reloadData()
            }
            
            //Kkeep workouts and refresh tableview in main thread
            
        })
    }
}

extension DateFormatter {
    func stringFromDate(date : Date) -> String{
        
        self.dateFormat = "yyyy-MM-ddHH:mm:ss";
        self.timeZone = TimeZone(abbreviation : "UTC")
         let dateString = self.string(from: date)
        return dateString;
    }
}

extension Date {
    func midNightDate() -> Date {
        let cal = Calendar(identifier: .gregorian)
        let newDate = cal.startOfDay(for: self)
        return newDate
    }
}
