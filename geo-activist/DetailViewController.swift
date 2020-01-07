//
//  DetailViewController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/07.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import UIKit
import HealthKit
import CoreLocation
import Social

class DetailViewController: UIViewController {
    
    var workout: HKWorkout? = nil
    var workoutName: String = ""
    private let healthKitStore: HKHealthStore = HKHealthStore()
    private var workoutRoutes: [HKWorkoutRoute] = []
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var energyBurnLabel: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        self.dateLabel?.text = formatter.string(from: self.workout!.startDate)
        
        self.workoutNameLabel?.text = self.workoutName
        self.distanceLabel?.text = String(format: "%@", workout?.totalDistance ?? "no data")
        self.energyBurnLabel?.text = String(format: "%@", workout?.totalEnergyBurned ?? "no data")
        
        self.exportButton.addTarget(self, action: #selector(self.buttonEvent), for: .touchUpInside)
    }
    
    @objc func buttonEvent() {
        
        self.readWorkoutRoutes({ (results, error) -> Void in
            if( error != nil ) {
                print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                return;
            }
            self.workoutRoutes = results! as! [HKWorkoutRoute]
            
            if(self.workoutRoutes.count == 0) {
                print("No routes")
                return;
            }
            
            let workoutRoute: HKWorkoutRoute = self.workoutRoutes[0]
            var allLocations: String = "timestamp,latitude,longitude,altitude\n"
            
            let routeQuery = HKWorkoutRouteQuery(route: workoutRoute) { query, locationsOrNil, done, errorOrNil in
                
                // This block may be called multiple times.
                
                if let error = errorOrNil {
                    // Handle any errors here.
                    return
                }
                
                guard let locations = locationsOrNil else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }
                
                // Do something with this batch of location data.
                
                locations.forEach { element in
                    allLocations += String(element.timestamp.timeIntervalSince1970) + ","
                    allLocations += String(element.coordinate.latitude) + ","
                    allLocations += String(element.coordinate.longitude) + ","
                    allLocations += String(element.altitude) + "\n"
                }
                
                if done {
                    
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                         let activityViewController = UIActivityViewController(activityItems: [allLocations], applicationActivities: nil)
                         activityViewController.popoverPresentationController?.sourceView = self.view // prevent crash
                         self.present(activityViewController, animated: true, completion: nil)
                        
                    });
                                        

                    // The query returned all the location data associated with the route.
                    // Do something with the complete data set.
                }
                
                // You can stop the query by calling:
                // store.stop(query)
                
            }
            
            self.healthKitStore.execute(routeQuery)
        })
    }
    
    private func readWorkoutRoutes(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForObjects(from: self.workout!)
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
        
        self.healthKitStore.execute(sampleQuery)
    }
}
