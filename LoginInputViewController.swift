//
//  LoginInputViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 5/2/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class LoginInputViewController: UIViewController {
    
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
        self.currentTextField.resignFirstResponder()
        if self.loginField.text == "111" && self.passwordField.text == "pwd"{
            self.openHomePageForPatient()
    }
    }
        
    func openHomePageForPatient() {
        let storyBoard = UIStoryboard(name : "Main", bundle : nil)
        let tabBarVC = storyBoard.instantiateInitialViewController()
        
        self.view.window?.rootViewController = tabBarVC
    }
}
