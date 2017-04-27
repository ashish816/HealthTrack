//
//  ActivityViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/11/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire
import FSCalendar

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource{
    
    let healthManager = HealthManager()
    var walkingAvg : Double = 0.0;
    var totalEnergyBurned: Double = 0;
    var totalStepCount : Double = 0.0;
    var glucoseAverage: Double = 0.0;
    
    @IBOutlet var activityTableView : UITableView!
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var datePickerButton : UIButton!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendar: FSCalendar!

    var runningWalkingSample = [HKQuantitySample]()
    var stepCountSample = [HKQuantitySample]()
    var glucoseSample = [HKQuantitySample]()

    var datePicked : Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authorizeHealthkit();
        
        self.activityTableView.separatorInset = UIEdgeInsets(top:10,left:10,bottom:10,right:10)
        self.activityTableView.layer.shadowRadius = 15;
        
        self.title = "Activity"
        datePicker.addTarget(self, action: #selector(ActivityViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        self.calendar.select(Date())
        self.calendar.scope = .week
        self.calendar.setScope(.week, animated: true)
        self.calendarHeightConstraint.constant = 200

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
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.datePicked = date
        self.getTotalRunningData(forDate: self.datePicked!)
        self.datePicker.isHidden = true
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    
    func datePickerChanged(datePicker:UIDatePicker){
        
//        self.datePicked = datePicker.date
//        self.getTotalRunningData(forDate: self.datePicked!)
//        self.datePicker.isHidden = true
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
                
                self.runningWalkingSample = results as! [HKQuantitySample]
                
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
                self.stepCountSample = results as! [HKQuantitySample]

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
        
        if segue.identifier == "ActivityToDetailActivity" {
            let destination = segue.destination as! DetailActivityViewController
            let indexPath = sender as! IndexPath
            if indexPath.row == 0{
                destination.detailActivitySamples = self.runningWalkingSample
                destination.currentDetailSampelType = .RunningType
            }else if indexPath.row == 1{
                destination.detailActivitySamples = self.stepCountSample
                destination.currentDetailSampelType = .StepCountType

            }else if indexPath.row == 2{
                
            }else if indexPath.row == 3{
                destination.detailActivitySamples = self.glucoseSample
                destination.currentDetailSampelType = .GlucoseType
            }
            
        }else{
            _ = segue.destination as! UserProfileViewController
 
        }
        
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
        
        cell.layer.cornerRadius = 10;
        cell.separatorInset = UIEdgeInsets(top:10,left:10,bottom:10,right:10)

        
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        self.performSegue(withIdentifier: "ActivityToDetailActivity", sender: indexPath)
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
                
                self.glucoseSample = results as! [HKQuantitySample]
                
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
                self.storeValuesToServer()
            }
            
        })
    }
    
    func storeValuesToServer() {
        
//        let parameters : Parameters = ["patientId" : 111, "name" : "ashish Mishra" , "age" : 28]
//        Alamofire.request("http://10.0.0.117:3000/patient/activites", method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
//            print(response)
//            
//        }
        
        self.syncAtcivityForCurrentDate()
        self.syncGlucoseDataForCurrentDate()
    }
    
    func syncAtcivityForCurrentDate() {
        
        let activityDic = ["WalkingRunningDistance" : self.walkingAvg, "StepCount" : self.totalStepCount , "Date" : self.datePicked?.iso8601] as [String : Any]
        
        let activityArray = [activityDic];
        
        let activityData : Parameters = ["patientId" : 111, "activity" : activityArray]
        Alamofire.request("http://10.0.0.117:9000/patient/activites", method: .post, parameters: activityData, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
        }
    }
    
    func syncGlucoseDataForCurrentDate() {
        
        
        var chosenDateGlucoseSampels = [Any]()
        
        let gramUnit = HKUnit.gram()
        let volumeUnit = HKUnit.literUnit(with: .deci)
        let glucoseUnit = gramUnit.unitDivided(by: volumeUnit)
        
        for aSample in self.glucoseSample {
        
            let timeSample = ["time" : aSample.startDate.iso8601 , "value" : aSample.quantity
                .doubleValue(for: glucoseUnit)] as [String : Any]
            
            chosenDateGlucoseSampels.append(timeSample)
            
        }

        let glucoseData : Parameters = ["patientId" : 111,"unit" : "mg/dL", "ObservationDate": self.datePicked?.iso8601 , "glucose": chosenDateGlucoseSampels]
        Alamofire.request("http://10.0.0.117:9000/patient/glucose", method: .post, parameters: glucoseData, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
        }
        
    }
}

extension DateFormatter {
    func stringFromDate(date : Date) -> String{
        
        self.dateFormat = "yyyy-MM-ddHH:mm:ss";
        self.timeZone = TimeZone(abbreviation : "UTC")
         let dateString = self.string(from: date)
        return dateString;
    }
    
    func stringFromDateWithCurrentTimeZone(date : Date) -> String {
        self.dateFormat = "YYYY-MM-DDTHH:mm:ss.sssZ";
        self.timeZone = TimeZone.current
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

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
