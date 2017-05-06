//
//  AppDelegate.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 2/26/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyBoard = UIStoryboard(name : "Login" , bundle: nil)
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginVC")
        
        self.window?.rootViewController = loginVC
        self.window?.makeKeyAndVisible()
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        self.setRemindersForFoodLogging()

        return true
    }
    
    func setRemindersForFoodLogging() {
      
        let center = UNUserNotificationCenter.current()
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = 8
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let userCalendar = Calendar.current // user calendar
        let someDateTime = userCalendar.date(from: dateComponents)
        let triggerDaily1 = Calendar.current.dateComponents([.hour,.minute,.second,], from: someDateTime!)
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: triggerDaily1, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Track your Calories"
        content.body = "Have you logged your Breakfast?"
        content.sound = UNNotificationSound.default()
        
        let identifier1 = "UYLBreakfast"
        let request1 = UNNotificationRequest(identifier: identifier1,
                                            content: content, trigger: trigger1)
        center.add(request1, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
        
        dateComponents.hour = 13
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let someDateTime1 = userCalendar.date(from: dateComponents)

        content.body = "Have you logged your Lunch?"
        let triggerDaily2 = Calendar.current.dateComponents([.hour,.minute,.second,], from: someDateTime1!)
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: triggerDaily2, repeats: true)
        
        let identifier2 = "UYLLunch"
        let request2 = UNNotificationRequest(identifier: identifier2,
                                            content: content, trigger: trigger2)
        center.add(request2, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
        
        dateComponents.hour = 20
        dateComponents.minute = 0
        dateComponents.second = 0
        
        let someDateTime2 = userCalendar.date(from: dateComponents)

        content.body = "Have you logged your Dinner?"
        
        let triggerDaily3 = Calendar.current.dateComponents([.hour,.minute,.second,], from: someDateTime2!)
        let trigger3 = UNCalendarNotificationTrigger(dateMatching: triggerDaily3, repeats: true)
        
        let identifier3 = "UYLDinner"
        let request3 = UNNotificationRequest(identifier: identifier3,
                                            content: content, trigger: trigger3)
        center.add(request3, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler([.alert,.badge])
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
