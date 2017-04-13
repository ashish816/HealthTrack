//
//  User.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/4/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import Foundation
import  HealthKit

class User {
    
    static let sharedInstance = User()
    
    let healthKitStore:HKHealthStore = HKHealthStore()

    var age: Int? {
        
        do {
            let birthDay = try healthKitStore.dateOfBirthComponents()
            let birthDate = (birthDay as NSDateComponents).date
            let today = Date() as Date
            _ = Calendar.current
            
            let differenceComponents = Calendar.current.dateComponents([.day, .month, .year, .hour] ,from: birthDate!, to: today)
            
            //                let differenceComponents = NSCalendar.current.components(.CalendarUnitYear, fromDate: birthDay, toDate: today, options: NSCalendar.Options(0) )
            return differenceComponents.year
        }
        catch {
            print("could not read age info from Healtkit")

        }
        
        return nil
        
    }
    
    var biologicalSex : String? {
        do {
         let sex = try healthKitStore.biologicalSex()
            
            switch sex.biologicalSex {
            case .female:
                return "Female"
            case .male:
                return "Male"
            default:
                return "Not Set"
            }
        }
        catch {
            print("could not read gender info from Healtkit")
        }
        
        return nil
        
    }
    
    var bloodType : String? {
    
        do {
            let bloodType = try healthKitStore.bloodType()
            
            switch bloodType.bloodType {
            case .aPositive:
                return "A+"
            case .aNegative:
                return "A-"
            case .bPositive:
                return "B+"
            case .bNegative:
                return "B-"
            case .abPositive:
                return "AB+"
            case .abNegative:
                return "AB-"
            case .oPositive:
                return "O+"
            case .oNegative:
                return "O-"
            case .notSet:
                return nil
            }
            
        }
        catch {
            print("Could not read blood type from Healthkit");
        }
        return nil
    
    }
    
}
