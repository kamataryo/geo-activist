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
import MapKit

enum LocationExportType {
    case csv
    case geoJSON
}

class WorkoutController {
    static let healthKitStore = HKHealthStore()
    static let activityNameDictionary = HKNameDictionary.get()
    
    private let workout: HKWorkout
    private var startLocation: CLLocation? = nil
    
    public var startDate: Date
    public var dateLabel: String = ""
    public var activityName: String = "(該当なし)"
    public var totalDistance: String = "-- km"
    public var totalEnergyBurned: String = "-- kcal"
    public var startLocationName: String =  "(不明な場所)"
    
    public var workoutRoute: HKWorkoutRoute? = nil
    
    public var csv = ""
    public var geoJSON = ""
    public var csvFilePath: String? = nil
    public var geoJSONFilePath: String? = nil
    public var polyline = MKPolyline()
    
    init(workout: HKWorkout) {
        self.workout = workout
        
        let totalDistanceValue = workout.totalDistance?.doubleValue(for: .init(from: .kilometer))
        let totalEnergyBurnedValue = workout.totalEnergyBurned?.doubleValue(for: .init(from: .kilocalorie))
        var totalDistance = "データなし"
        var totalEnergyBurned = "データなし"
        
        if totalDistanceValue != nil {
            totalDistance = String((totalDistanceValue! * 100).rounded() / 100) + " km"
        }
        
        if totalEnergyBurnedValue != nil {
            totalEnergyBurned = String(Int(totalEnergyBurnedValue!.rounded())) + " kcal"
        }

        self.startDate = workout.startDate
        self.activityName = WorkoutController.activityNameDictionary[workout.workoutActivityType.rawValue]?.ja ?? "(該当なし)"
        self.totalDistance = totalDistance
        self.totalEnergyBurned = totalEnergyBurned
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
                    
                    done()
                    // geoCoording should be once a minute ٩(๑❛ᴗ❛๑)۶
//                    self.readPlaceName(location: startLocation) { startLocationName in
//                        self.startLocationName = startLocationName
//                        done()
//                    }
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
            
            if (errorOrNil != nil) {
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
                    return element != ""
                }
                var startPlaceName = elements.joined(separator: ", ")
                if startPlaceName == "" {
                    startPlaceName = "(不明な場所)"
                }
                completion(startPlaceName)
            }
        }
    }
    
    public func getAllLocations(locationExportType: LocationExportType, completion: @escaping (_ allLocations: String, _ filePath: String?) -> Void) {
        
        
        self.csv = "timestamp,latitude,longitude,altitude\n"
        self.geoJSON = "{\n"
        self.geoJSON += "\"type\":\"FeatureCollection\","
        self.geoJSON += "\"features\":["
        self.geoJSON += "{"
        self.geoJSON += "\"type\": \"Feature\","
        self.geoJSON += "\"geometry\":{"
        self.geoJSON += "\"type\": \"LineString\","
        self.geoJSON += "\"coordinates\":["
        self.polyline = MKPolyline()
        var coordinates: [CLLocationCoordinate2D] = []
        
        let routeQuery = HKWorkoutRouteQuery(route: self.workoutRoute!) { query, locationsOrNil, done, errorOrNil in
            
            if (errorOrNil != nil) {
                completion("", nil)
                // Handle any errors here.
                return
            }
            
            guard let locations = locationsOrNil else {
                fatalError("*** Invalid State: This can only fail if there was an error. ***")
            }
            
            locations.forEach { element in
                let timestamp = String(element.timestamp.timeIntervalSince1970)
                let latitude = String(element.coordinate.latitude)
                let longitude = String(element.coordinate.longitude)
                let altitude = String(element.altitude)
                
                self.csv += timestamp + ","
                self.csv += latitude + ","
                self.csv += longitude + ","
                self.csv += altitude + "\n"
                
                self.geoJSON += "[" + longitude + "," + latitude + "],"
                
                coordinates.append(element.coordinate)
            }
            
            if done {
                self.geoJSON.removeLast(1)
                self.geoJSON += "]"
                self.geoJSON += "}"
                self.geoJSON += "}"
                self.geoJSON += "]"
                self.geoJSON += "}"
                
                self.polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                
                
                let fileBaseName = NSTemporaryDirectory() + self.dateLabel + "-" + self.activityName
                let csvFilePath = fileBaseName + ".csv"
                let geoJsonFilePath = fileBaseName + ".geojson"
                
                do {
                    try self.csv.write(toFile: csvFilePath, atomically: true, encoding: String.Encoding.utf8)
                    self.csvFilePath = csvFilePath
                } catch {
                    print("failed to write csv file")
                }
                do {
                    try self.geoJSON.write(toFile: geoJsonFilePath, atomically: true, encoding: String.Encoding.utf8)
                    self.geoJSONFilePath = geoJsonFilePath
                } catch {
                    print("failed to write geoJSON file")
                }
                
                if(locationExportType == .csv) {
                    completion(self.csv, self.csvFilePath)
                } else if(locationExportType == .geoJSON) {
                    completion(self.geoJSON, self.geoJSONFilePath)
                } else {
                    completion("", nil)
                }
            }
        }
        
        WorkoutController.healthKitStore.execute(routeQuery)
    }
}
