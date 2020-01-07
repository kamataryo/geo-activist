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
    private var workoutsForDate: Dictionary<String, [HKWorkout]> = [:]
    private var workoutDatesArray: [String] = []
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

                    let formatter = DateFormatter()
                    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
                    
                    self.workouts.forEach { workout in
                        let workoutDate = formatter.string(from: workout.startDate)
                        if((self.workoutsForDate[workoutDate]) != nil) {
                            self.workoutsForDate[workoutDate]!.append(workout)
                        } else {
                            self.workoutsForDate[workoutDate] = [workout]
                        }
                    }
                    for (key, _) in self.workoutsForDate {
                        self.workoutDatesArray.append(key)
                     }
                    self.workoutDatesArray.sort()
                    
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                    });
                })
            }
        }
    }
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutDatesArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.workoutDatesArray[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let workoutDate = self.workoutDatesArray[section]
        return self.workoutsForDate[workoutDate]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let workoutDate = self.workoutDatesArray[indexPath.section]
        let workout = self.workoutsForDate[workoutDate]![indexPath.row]
        let activityName = self.activityNames[workout.workoutActivityType.rawValue] ?? "(no data)"
        let distance = String(format: "%@", workout.totalDistance ?? "(no data)")
        
        cell.textLabel?.text = activityName + " " + distance
        
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workoutDate = self.workoutDatesArray[indexPath.section]
        let workout = self.workoutsForDate[workoutDate]![indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: workout)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destination = segue.destination as! DetailViewController
            let workout = sender as? HKWorkout
            destination.workout = workout
            destination.workoutName = self.activityNames[workout!.workoutActivityType.rawValue] ?? "no data"
            
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            destination.workoutStart = formatter.string(from: workout!.startDate)
        }
    }
}
