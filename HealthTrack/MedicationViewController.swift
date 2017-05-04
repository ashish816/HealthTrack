//
//  MedicationViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 4/9/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import UserNotifications

class MedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var medicationtableView : UITableView!
    
    var medicationDetails = [MedicationSample]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Medication"

        
        var medication1 = MedicationSample()
        medication1.medicationName = "med1";
        medication1.medicationTime = "8"
        
        var medication2 = MedicationSample()
        medication2.medicationName = "med2";
        medication2.medicationTime = "13"
        
        var medication3 = MedicationSample()
        medication3.medicationName = "med3";
        medication3.medicationTime = "19"
        
        self.medicationDetails = [medication1, medication2, medication3]
        
        self.createNotificationsForMedicine()

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
        tableCell.frequncyLAbel?.text = medicationSample.medicationTime

        return tableCell
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
