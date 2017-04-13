//
//  UserProfileViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/11/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "\(User.sharedInstance.age!)"
        }else if indexPath.row == 1{
            cell.textLabel?.text = "\(User.sharedInstance.biologicalSex!)"

        }else if indexPath.row == 2{
            cell.textLabel?.text = "\(User.sharedInstance.bloodType!)"

        }
        
        return cell;
    }
    
    @IBAction func dismissUserProfile() {
        self.dismiss(animated: true, completion: nil)
    }
}
