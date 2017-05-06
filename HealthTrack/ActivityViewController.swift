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
import CoreLocation
import CoreMotion
import SystemConfiguration.CaptiveNetwork


class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource,CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var isFirstRequestFromRange : Bool = false
    var isFirstRequestOutsideRange : Bool = false
    var inRangeStatus : String?
    @IBOutlet var rSSILabel : UILabel!
    
    let healthManager = HealthManager()
    var walkingAvg : Double = 0.0;
    var totalEnergyBurned: Double = 0;
    var totalStepCount : Double = 0.0;
    var glucoseAverage: Double = 0.0;
    var totalCalorieConsumed: Double = 0;
    
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
    
    func fetchCalorieData() {
//        let calorieParam : Parameters = ["patientid" : "111","date": self.datePicked?.iso8601]
        let dateString = self.datePicked!.iso8601
        let url = SERVER_PATH + "patient/calories?"+"patientId=111&date="+"\(dateString)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).response { (response) in
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    print("example success")
                default:
                    print("error with response status: \(status)")
                }
            }
            //to get JSON return value
            if let result = response.data {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: result, options: []) as! [String:Any]
                    
                    let calorieDic = parsedData["calories"] as! [String : Any]
                    let burned = calorieDic["burned"]
                    let consumed = calorieDic["intake"]
                    
                    self.totalEnergyBurned = Double(burned as! Int)
                    self.totalCalorieConsumed = Double(consumed as! Int)

                    print(parsedData)
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.activityTableView.reloadData()
                        self.storeValuesToServer()
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.activityTableView.reloadData()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
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
        return 6
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityVCCell", for: indexPath) as! ActivityTrackCell
        
        cell.layer.cornerRadius = 10;
        cell.separatorInset = UIEdgeInsets(top:10,left:10,bottom:10,right:10)

        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.red.cgColor]
//        gradientLayer.locations = [0.4, 1.0]
        gradientLayer.frame = cell.bounds
        cell.layer.insertSublayer(gradientLayer, at: 0)
        
         if indexPath.row == 0{
            cell.activityTypeLabel?.text = "Daily Goal";
            cell.activityTypleValue?.text = "\(goalForTheDay)"
        }
        else if indexPath.row == 1 {
            
            var myString = NSMutableAttributedString()
            let myAttribute1 = [ NSFontAttributeName: UIFont.systemFont(ofSize: 32)]
            
            let myAttribute2 = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16) ]
            
            let twoDecimalPlaces = String(format: "%.2f", self.walkingAvg)
            
            let myAttrString1 = NSAttributedString(string: twoDecimalPlaces, attributes: myAttribute1)
            let myAttrString2 = NSAttributedString(string: "mi", attributes: myAttribute2)
            
            myString.append(myAttrString1)
            myString.append(myAttrString2)
            
            cell.activityTypeLabel?.text = "WalkingRunningDistance";
            cell.activityTypleValue?.attributedText = myString
        }else if indexPath.row == 2{
            cell.activityTypeLabel?.text = "StepCount";
            cell.activityTypleValue?.text = "\(self.totalStepCount)"
        }else if indexPath.row == 3{
            cell.activityTypeLabel?.text = "CaloriesBurned";
            cell.activityTypleValue?.text = "\(self.totalEnergyBurned)"
            
        }else if indexPath.row == 4{
            cell.activityTypeLabel?.text = "GlucoseAverage";
            cell.activityTypleValue?.text = "\(self.glucoseAverage)"
         }else if indexPath.row == 5{
            cell.activityTypeLabel?.text = "Calorie Consumed";
            cell.activityTypleValue?.text = "\(self.totalCalorieConsumed)"
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
                self.fetchCalorieData()
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
        let url = SERVER_PATH + "patient/activites"
        Alamofire.request(url, method: .post, parameters: activityData, encoding: JSONEncoding.default).response { (response) in
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
        let url = SERVER_PATH + "patient/glucose"
        
        Alamofire.request(url, method: .post, parameters: glucoseData, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error as NSError).description")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error as NSError).description")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    
//                    if UserDefaults.standard.value(forKey: "userid") != nil{
                        startScanning()
                        
//                    }
                    
                }
            }
        }
    }
    
    
    func startScanning() {
        let uuid1 = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let beaconRegion1 = CLBeaconRegion(proximityUUID: uuid1!, major: 45605, minor: 37735, identifier: "MyBeacon1")
        
        //        let beaconRegion1 = CLBeaconRegion(proximityUUID: uuid1!, identifier: "MyBeacon1")
        
        locationManager.startMonitoring(for: beaconRegion1)
        locationManager.startRangingBeacons(in: beaconRegion1)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacons = beacons as? [CLBeacon] {
            if region.identifier == "MyBeacon1" && beacons.count > 0 {
                
                self.title = "RSSI :" + "\(beacons[0].rssi)"
                
                if beacons.count > 0 {
                    self.calculateStrengthAndPlay(beacons[0])
                }
            }
        }
    }
    
    func calculateStrengthAndPlay( _ beacon : CLBeacon) {
        
        if beacon.rssi > -70  {
            self.inRangeStatus = "yes"
            self.isFirstRequestOutsideRange = false
            
            if self.isFirstRequestFromRange {
                
                return
            }
            
            self.sendRequest(inrangestatus: self.inRangeStatus!)
            
        } else{
            self.inRangeStatus = "no"
            self.isFirstRequestFromRange = false
            
            if self.isFirstRequestOutsideRange {
                return
            }
            
            self.sendRequest(inrangestatus: self.inRangeStatus!)
            
        }
    }
    
    func sendRequest(inrangestatus : String) {
        
        if inrangestatus == "yes"{
            self.isFirstRequestFromRange = true
        }
        else {
            self.isFirstRequestOutsideRange = true
        }
        
        let beaconData : Parameters = ["name" : "Jessica","id" : 1]
        let url = SERVER_PATH + "socketEmit"
        
        Alamofire.request(url, method: .post, parameters: beaconData, encoding: JSONEncoding.default).response { (response) in
            print(response)
        
        }
        
        print(inrangestatus)
        self.showAlert("Request Sent", message: "In Range: " + inrangestatus)
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

