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
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.activityTableView.reloadData()
            }
            
            //Kkeep workouts and refresh tableview in main thread
            
        })
    }
    
    func getTotalCalorieBurned(forDate: Date) {
        healthManager.readCalorieBurned({ (results, error) -> Void in
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityVCCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "WalkingRunningDistance";
            cell.detailTextLabel?.text = "\(self.walkingAvg)"
        }else if indexPath.row == 1{
            cell.textLabel?.text = "StepCount";
            cell.detailTextLabel?.text = "\(self.totalStepCount)"
        }else if indexPath.row == 2{
            cell.textLabel?.text = "CaloriesBurned";
            cell.detailTextLabel?.text = "\(self.totalEnergyBurned)"
            
        }
        return cell;
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
