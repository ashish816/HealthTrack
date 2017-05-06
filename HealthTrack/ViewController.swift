//
//  ViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 2/26/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire

class ViewController: UIViewController {
    
    let healthManager = HealthManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.storeValuesToServer();
    }
    
    func storeValuesToServer() {
        
        let parameters : Parameters = ["patientId" : 111, "name" : "ashish Mishra" , "age" : 28]
        Alamofire.request("http://10.0.0.117:3000/patient/activites", method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            print(response)
        }
    }

}

