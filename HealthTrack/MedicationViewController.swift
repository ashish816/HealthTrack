//
//  MedicationViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/9/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire

class MedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var medicationtableView : UITableView!
    
    var medicationDetails = [MedicationSample]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Medication"

        self.createNotificationsForMedicine()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchmedicationDetails()
    }
    
    func fetchmedicationDetails() {
        
        let loginId = UserDefaults.standard.value(forKey: "userid")
        let wtDic = ["data" : "\(loginId!)"] as [String : Any]
        
        let userInfo : Parameters = wtDic
        let url = SERVER_PATH + "doctor/patientMedications"
        
        Alamofire.request(url, method: .post, parameters: userInfo, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
            if let result = response.data {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: result, options: []) as! [Any]
                    
                    var medications = [MedicationSample]()
                    for aObject in parsedData {
                    
                        var medicalrecord = aObject as? Dictionary<String, String>
                        let medicationSample = MedicationSample()
                        medicationSample.medicationName = medicalrecord?["name"]
                        medicationSample.dosage = medicalrecord?["dosage"]
                        medicationSample.medicationTime = medicalrecord?["timing"]
                        
                        medications.append(medicationSample)
                    }
                    
                    self.medicationDetails = medications
                    DispatchQueue.main.async { [unowned self] in
                        self.medicationtableView.reloadData()
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    func createNotificationsForMedicine(){
        let content = UNMutableNotificationContent()
        content.title = "Medicine Name"
        content.body = "Its time to take your Medicine"
        content.sound = UNNotificationSound.default()
        
        let date = Date()
        
        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        
        let center = UNUserNotificationCenter.current()

        let identifier = "UYLMedication"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medicationDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell") as! MedicationTableViewCell
        
        var medicationSample = self.medicationDetails[indexPath.row] as MedicationSample
        
        tableCell.medicationName.text = medicationSample.medicationName
        tableCell.frequncyLAbel?.text = medicationSample.dosage
        tableCell.timing?.text = medicationSample.medicationTime

        return tableCell
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
