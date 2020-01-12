//
//  WorkoutController.swift
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
    static let activityNameDictionary = HKNameDictionary.get()
    
    private let workout: HKWorkout
    private var workoutRoute: HKWorkoutRoute? = nil
    private var startLocation: CLLocation? = nil
    
    public var startDate: Date
    public var activityName: String = "(該当なし)"
    public var totalDistance: String = "-- km"
    public var startLocationName: String =  "(不明な場所)"
    
    init(workout: HKWorkout) {
        self.workout = workout
        
        self.startDate = workout.startDate
        self.activityName = WorkoutController.activityNameDictionary[workout.workoutActivityType.rawValue]?.ja ?? "(該当なし)"
        self.totalDistance = String(format: "%@", workout.totalDistance ?? "")
    }
    
    public func query(done: @escaping () -> Void) {
        self.readWorkoutRoutes(workout: workout) { (results, error) in
            let workoutRoutes = results as! [HKWorkoutRoute]
            if workoutRoutes.count > 0 {
                let workoutRoute = workoutRoutes[0]
                self.workoutRoute = workoutRoute
                self.readWorkoutStartLocation(workoutRoute: workoutRoute) { (result, error) in
                    let startLocation = result as! CLLocation
                    self.startLocation = startLocation
                    self.readPlaceName(location: startLocation) { startLocationName in
                        self.startLocationName = startLocationName
                        done()
                    }
                }
            } else {
                done()
            }
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
    
    private func readPlaceName(location: CLLocation, _ completion: ((String) -> Void)!) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if placemarks == nil {
                completion("(不明な場所)")
            } else {
                let placemark = placemarks!.first
                let elements = ([
                    placemark?.locality ?? "",
                    placemark?.subLocality ?? ""
                ]).filter { element in
                    return element != "" && element != nil
                }
                var startPlaceName = elements.joined(separator: ", ")
                if startPlaceName == "" {
                    startPlaceName = "(不明な場所)"
                }
                completion(startPlaceName)
            }
        }
    }
}
