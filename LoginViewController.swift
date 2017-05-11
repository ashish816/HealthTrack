//
//  LoginViewController.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 5/2/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var startButton : UIButton!
    @IBOutlet weak var signUpImage : UIImageView!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var textView : UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.backgroundColor = UIColor.clear
        
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        //2
        textView.textAlignment = .center
        textView.text = "Healthify is the solution for your activity and diabetic tracking."
//        textView.textColor = .black
        self.startButton.layer.cornerRadius = 4.0
        //3
        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgOne.image = UIImage(named: "Slide1")
        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgTwo.image = UIImage(named: "Slide2")
        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgThree.image = UIImage(named: "Slide3")
        let imgFour = UIImageView(frame: CGRect(x:scrollViewWidth*3, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgFour.image = UIImage(named: "Slide4")
        
        self.scrollView.addSubview(imgOne)
        self.scrollView.addSubview(imgTwo)
        self.scrollView.addSubview(imgThree)
        self.scrollView.addSubview(imgFour)
        //4
        
        self.pageControl.numberOfPages = 4
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0{
            textView.text = "Healthify is the solution for your activity and diabetic tracking."
        }else if Int(currentPage) == 1{
            textView.text = "Save your glucose level, Calorie consumption and calorie burned."
        }else if Int(currentPage) == 2{
            textView.text = "Get reminders for medication and logging your activities. "
        }else{
            textView.text = "Get prediction for medication, readmission status and glucose level. "
            // Show the "Let's Start" button in the last slide (with a fade in animation)                     UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.startButton.alpha = 1.0
        }
    }
    
}
    
