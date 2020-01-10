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
    private let refreshControl = UIRefreshControl()
    
    // HealthKit
    private let healthKitStore: HKHealthStore = HKHealthStore()
    private let activityNames = HKNameDictionary.get()
    private var workouts: [HKWorkout] = []
    private var workoutsForDate: Dictionary<String, [HKWorkout]> = [:]
    private var workoutDateKeysArray: [String] = []
    private var sectionDateKeyDictionary: Dictionary<String, String> = [:]
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.frame = view.bounds
        self.tableView.dataSource = self
        view.addSubview(tableView)
        self.tableView.delegate = self
        
        self.healthKitStore.requestAuthorization(toShare: nil, read: self.readDataTypes) {
            (success, error) -> Void in
            if (success == false) {
                DispatchQueue.main.async(execute: { () -> Void in
                    let alert = UIAlertController(title: "ワークアウトへのアクセス権限が必要です", message: "設定 -> ヘルスケア -> データアクセスとデバイスから、GeoActivist にワークアウトのデータを読み出す権限を与えて下さい。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                })
            } else {
                self.refresh()
            }
        }
    }
    
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
            completion!(results, error as NSError?)
        }
        self.healthKitStore.execute(sampleQuery)
    }
    
    func refresh() {
        self.readWorkouts({ (workouts, error) -> Void in
            if( error != nil ) {
                print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                return;
            }
            
            self.workouts = workouts! as! [HKWorkout]
            
            let sectionDateLabelformatter = DateFormatter()
            sectionDateLabelformatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            
            let sectionDateLabelAsSortKeyformatter = DateFormatter()
            sectionDateLabelAsSortKeyformatter.dateFormat = "YYYYMMDD"
            sectionDateLabelAsSortKeyformatter.timeZone = TimeZone.current
            
            self.workouts.forEach { workout in
                let x = WorkoutController(workout: workout)
                
                let workoutDateKey = sectionDateLabelAsSortKeyformatter.string(from: workout.startDate)
                if((self.workoutsForDate[workoutDateKey]) != nil) {
                    self.workoutsForDate[workoutDateKey]!.append(workout)
                } else {
                    self.workoutsForDate[workoutDateKey] = [workout]
                    self.sectionDateKeyDictionary[workoutDateKey] = sectionDateLabelformatter.string(from: workout.startDate)
                }
            }
            
            for (key, _) in self.workoutsForDate {
                self.workoutDateKeysArray.append(key)
            }
            self.workoutDateKeysArray.sort(by: >)
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            });
        })
    }
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutDateKeysArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionDateKeyDictionary[workoutDateKeysArray[section]]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let workoutDate = self.workoutDateKeysArray[section]
        return self.workoutsForDate[workoutDate]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let workoutDate = self.workoutDateKeysArray[indexPath.section]
        let workout = self.workoutsForDate[workoutDate]![indexPath.row]
        let activityName = self.activityNames[workout.workoutActivityType.rawValue]?.ja ?? "(該当なし)"
        let distance = String(format: "%@", workout.totalDistance ?? "")
        cell.textLabel?.text = activityName + " " + distance
        cell.textLabel?.textAlignment = .natural
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workoutDate = self.workoutDateKeysArray[indexPath.section]
        let workout = self.workoutsForDate[workoutDate]![indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: workout)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destination = segue.destination as! DetailViewController
            let workout = sender as? HKWorkout
            destination.workout = workout
            destination.workoutName = self.activityNames[workout!.workoutActivityType.rawValue]?.ja ?? "(種別不明)"
            
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            destination.workoutStart = formatter.string(from: workout!.startDate)
        }
    }
}
