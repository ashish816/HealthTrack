//
//  LoginInputViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 5/2/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import Alamofire

class LoginInputViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var PasswordContainer : UIView!
    @IBOutlet var loginContainer : UIView!
    
    @IBOutlet var loginField : GSTextField!
    @IBOutlet var passwordField : GSTextField!
    
    @IBOutlet weak var greystoneLogo: UIImageView!
    
    @IBOutlet weak var topLayoutConstraint : NSLayoutConstraint!
    
    var currentTextField : UITextField = UITextField()
    
    var isKeyboardPresent : Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginField.attributedPlaceholder = NSAttributedString(string:"Username",
                                                                   attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                      attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.loginField.leftTextMargin = 30;
        self.passwordField.leftTextMargin = 30;
        self.loginField.layoutIfNeeded()
        self.passwordField.layoutIfNeeded()

        // Do any additional setup after loading the view.
    }

    func keyboardWillShow(notification:NSNotification){
        
        if self.isKeyboardPresent == true {
            return
        }
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.topLayoutConstraint.constant -= keyboardFrame.height
        self.isKeyboardPresent = true
    }
    
    func keyboardWillHide(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.topLayoutConstraint.constant += keyboardFrame.height
        self.isKeyboardPresent = false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        self.currentTextField = textField
        if self.currentTextField.isFirstResponder {
            self.currentTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginClicked(sender : UIButton) {
        self.view.endEditing(true)
        let activityDic = ["email" : self.loginField.text] as [String : Any]
        let loginDic = ["data" : activityDic]
        
        let activityData : Parameters = activityDic
        let url = SERVER_PATH + "doctor/loginCheck"
        Alamofire.request(url, method: .post, parameters: loginDic, encoding: JSONEncoding.default).response { (response) in
            print(response)
            
            if let result = response.data {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: result, options: []) as! [String:Any]
                    
                    UserDefaults.standard.set(parsedData["id"], forKey: "userid")
                    UserDefaults.standard.set(parsedData["name"], forKey: "username")

                    DispatchQueue.main.async { [unowned self] in
                        self.openHomePageForPatient()
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }
    }
        
    func openHomePageForPatient() {
        let storyBoard = UIStoryboard(name : "Main", bundle : nil)
        let tabBarVC = storyBoard.instantiateInitialViewController()
        self.view.window?.rootViewController = tabBarVC
    }
}
