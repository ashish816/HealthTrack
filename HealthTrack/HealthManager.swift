//
//  HealthManager.swift
//  HealthTrack
//
//  Created by Ashish Mishra on 3/2/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    
    func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
            HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            HKObjectType.workoutType()
        ]
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite : Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)!,
            HKQuantityType.workoutType()
        ]
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "HealthTrack", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion?(false, error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion?(success,error as NSError?)
            }
        }
    }
    
    func readRunningWorkOuts(forDate : Date?,_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        
        
        let chosenDate = forDate != nil ? forDate! : Date();
        
        let startDate = chosenDate.midNightDate()

//        let startDate = Date()
        let endDate = startDate.addingTimeInterval(24*60*60)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [.strictStartDate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        
        let distanceSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!;
        

        let sampleQuery = HKSampleQuery(sampleType: distanceSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor])
            
            
        { (sampleQuery, results, error ) -> Void in
            
            if let queryError = error {
                print( "There was an error while reading the samples: \(queryError.localizedDescription)")
            }
            else {
                print(results)
                
                completion?(results,error as NSError?);
                
            }
        }
        healthKitStore.execute(sampleQuery)
        
    }
    
    func readCalorieBurned(forDate : Date?,_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        
        let chosenDate = forDate != nil ? forDate! : Date();
        
        let startDate = chosenDate.midNightDate()
        let endDate = startDate.addingTimeInterval(24*60*60)
        
         let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [.strictStartDate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        
        
        let calorieBurned = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        
        
        let calorieBurnedQuery = HKSampleQuery(sampleType: calorieBurned!,
                                               predicate: predicate,
                                               limit: HKObjectQueryNoLimit,
                                               sortDescriptors: [sortDescriptor])
        { [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                completion?(results,error as NSError?);
               
            }
        }
        
        // Don't forget to execute the Query!
        healthKitStore.execute(calorieBurnedQuery)
        
    }
    
    func readStepCount(forDate : Date?,_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        
        let chosenDate = forDate != nil ? forDate! : Date();
        
        let startDate = chosenDate.midNightDate()//        let startDate = Date()
        let endDate = startDate.addingTimeInterval(24*60*60)
        
         let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [.strictStartDate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        let stepsCount = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        var totalStepCount : Double = 0;
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
                                             predicate: predicate,
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: [sortDescriptor])
        { [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                
                completion?(results,error as NSError?);

            }
        }
        
        // Don't forget to execute the Query!
        healthKitStore.execute(stepsSampleQuery)
        
    }
    
    func readGlucoseSamples(forDate : Date?,_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        
        
        
        let chosenDate = forDate != nil ? forDate! : Date();
        
        print(chosenDate);
        
        let startDate = chosenDate.midNightDate()
        
        print(chosenDate);

        //        let startDate = Date()
        let endDate = startDate.addingTimeInterval(24*60*60)
        
         let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date, options: [.strictStartDate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        let stepsCount = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.bloodGlucose)
        
        var totalStepCount : Double = 0;
        
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
                                             predicate: predicate,
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: [sortDescriptor])
        { [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                
                completion?(results,error as NSError?);
                
            }
        }
        
        // Don't forget to execute the Query!
        healthKitStore.execute(stepsSampleQuery)
        
    }
}
