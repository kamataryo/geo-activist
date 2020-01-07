//
//  ListViewController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/06.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import UIKit
import HealthKit

class ListViewController: UIViewController {
    
    // Views
    private let tableView = UITableView()
    
    // HealthKit
    private let healthKitStore: HKHealthStore = HKHealthStore()
    private let activityNames = HKNameDictionary.get()
    private var workouts: [HKWorkout] = []
    private var workoutRoutes: [HKWorkoutRoute] = []
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
    ]
    
    private func readWorkouts(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
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
    
    
    private func readWorkoutRoutes(_ completion: (([AnyObject]?, NSError?) -> Void)!) {
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
        super.viewDidLoad()
        
        self.tableView.frame = view.bounds
        self.tableView.dataSource = self
        view.addSubview(tableView)
        self.tableView.delegate = self
        
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
                        self.tableView.reloadData()
                    });
                })
                
                self.readWorkoutRoutes({ (results, error) -> Void in
                    if( error != nil ) {
                        print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                        return;
                    }
                    self.workoutRoutes = results as! [HKWorkoutRoute]
                    DispatchQueue.main.async(execute: { () -> Void in });
                })
                
            }
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let workout = self.workouts[indexPath.row]
        let activityName = self.activityNames[workout.workoutActivityType.rawValue] ?? "no data"
        let distance = String(format: "%@", workout.totalDistance ?? "no data")
        let energyBurn = String(format: "%@", workout.totalEnergyBurned ?? "no data")
        cell.textLabel?.textAlignment = NSTextAlignment.justified
        cell.textLabel?.text = activityName + " " + distance + " " + energyBurn
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workout = self.workouts[indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: workout)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destination = segue.destination as! DetailViewController
            let workout = sender as? HKWorkout
            destination.workout = workout
            destination.workoutName = self.activityNames[workout!.workoutActivityType.rawValue] ?? "no data"
        }
    }
}
