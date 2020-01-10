//
//  WorkoutsController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/10.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import Foundation
import HealthKit
import CoreLocation

class WorkoutController {
    static let healthKitStore = HKHealthStore()
    
    private let workout: HKWorkout
    private var workoutRoute: HKWorkoutRoute? = nil
    private var startLocation: CLLocation? = nil
    
    init(workout: HKWorkout) {
        self.workout = workout
        
        self.readWorkoutRoutes(workout: workout) { (results, error) in
            let workoutRoutes = results as! [HKWorkoutRoute]
            
            if workoutRoutes.count > 0 {
                let workoutRoute = workoutRoutes[0]
                self.workoutRoute = workoutRoute
                
                self.readWorkoutStartLocation(workoutRoute: workoutRoute) { (result, error) in
                    let startLocation = result as! CLLocation
                    self.startLocation = startLocation
                }
            }
            print("ready")
        }
    }
    
    private func readWorkoutRoutes(workout: HKWorkout, _ completion: (([AnyObject]?, NSError?) -> Void)!) {
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForObjects(from: workout)
        let sampleQuery = HKSampleQuery(
            sampleType: HKSeriesType.workoutRoute(),
            predicate: predicate,
            limit: 0,
            sortDescriptors: [sortDescriptor]
        ) {
            (sampleQuery, results, error ) -> Void in
            if error != nil {
                print("Route query error")
            }
            completion!(results, error as NSError?)
        }
        WorkoutController.healthKitStore.execute(sampleQuery)
    }
    
    private func readWorkoutStartLocation(workoutRoute: HKWorkoutRoute, _ completion: ((AnyObject?, NSError?) -> Void)!) {
        let routeQuery = HKWorkoutRouteQuery(route: workoutRoute) { query, locationsOrNil, done, errorOrNil in

            if let error = errorOrNil {
                print("Location query error")
                return
            }
            guard let locations = locationsOrNil else {
                fatalError("*** Invalid State: This can only fail if there was an error. ***")
            }
            completion!(locations[0], errorOrNil as NSError?)
            WorkoutController.healthKitStore.stop(query)
        }
        WorkoutController.healthKitStore.execute(routeQuery)
    }
}
