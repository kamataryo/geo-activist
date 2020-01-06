//
//  ViewController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/06.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
        
    let healthKitStore: HKHealthStore = HKHealthStore()
    var workouts: [HKWorkout] = []
    var workoutRoutes: [HKWorkoutRoute] = []
    
    let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
        HKSeriesType.workoutRoute(),
    ]
    
    func readWorkouts(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(
            sampleType: HKWorkoutType.workoutType(),
            predicate: nil,
            limit: 0,
            sortDescriptors: [sortDescriptor]
        ) {
            (sampleQuery, results, error ) -> Void in
            if error != nil {
                print("Query Error")
            }
            completion!(results,error as NSError?)
        }
        
        self.healthKitStore.execute(sampleQuery)
    }
    
    
    func readWorkoutRoutes(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(
            sampleType: HKSeriesType.workoutRoute(),
            predicate: nil,
            limit: 0,
            sortDescriptors: [sortDescriptor]
        ) {
            (sampleQuery, results, error ) -> Void in
            if error != nil {
                print("Query Error")
            }
            completion!(results,error as NSError?)
        }
        
        self.healthKitStore.execute(sampleQuery)
    }
    
    
    override func viewDidLoad() {
        print("hello")
        super.viewDidLoad()
        self.healthKitStore.requestAuthorization(toShare: nil, read: self.readDataTypes) {
            (success, error) -> Void in
            if success == false {
                print("Ops, We can't get your permission.")
            } else {
                print("Yeah! We get the permission!")
                
                self.readWorkouts({ (results, error) -> Void in
                    if( error != nil ) {
                        print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                        return;
                    }
                    
                    self.workouts = results as! [HKWorkout]
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        for workout in self.workouts {
                            print(workout.duration)
                            print(workout.workoutActivityType.rawValue)
                            print(workout.startDate)
                            print(workout.endDate)
                            print(String(format: "Distance   : %@", workout.totalDistance ?? "no data"))
                            print(String(format: "EnergyBurn : %@", workout.totalEnergyBurned ?? "no data"))
                        }
                    });
                })
                
                self.readWorkoutRoutes({ (results, error) -> Void in
                    if( error != nil ) {
                        print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                        return;
                    }
                    self.workoutRoutes = results as! [HKWorkoutRoute]
                    DispatchQueue.main.async(execute: { () -> Void in
                        for route in self.workoutRoutes {
                            print("")
                        }
                    });
                })
                
            }
        }
    }
    
    
}

