//
//  ListViewController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/06.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class ListViewController: UIViewController {
    
    var _count = 0
    
    // Views
    private let tableView = UITableView(frame: CGRect(), style: .grouped)
    private let refreshControl = UIRefreshControl()

    // HealthKit
    private let healthKitStore: HKHealthStore = HKHealthStore()
    private var workoutCollectionController = WorkoutCollecitonController()
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
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.healthKitStore.requestAuthorization(toShare: nil, read: self.readDataTypes) {
            (success, error) -> Void in
            if (success == false) {
                DispatchQueue.main.async(execute: { () -> Void in
                    let alert = UIAlertController(title: "ワークアウトへのアクセス権限が必要です", message: "設定 -> ヘルスケア -> データアクセスとデバイスから、GeoActivist にワークアウトのデータを読み出す権限を与えて下さい。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                })
            } else {
                self.refresh(pulled: false)
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
    
    @objc func pullToRefresh(_ sender: Any) {
        self.workoutCollectionController.clear()
        self.refresh(pulled: true)
    }
    func refresh(pulled: Bool) {
        self.readWorkouts({ (workouts, error) -> Void in
            if( error != nil ) {
                print("Error reading workouts")
                return;
            }
            
            let workouts = workouts! as! [HKWorkout]
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "workout-queries")
            
            for workout in workouts {
                group.enter()
                queue.async(group: group) {
                    print("a")
                    self.workoutCollectionController.append(workout: workout, done: group.leave)
                }
            }
            
            group.notify(queue: .main) {
                print("notified")
                if pulled {
                    self.refreshControl.endRefreshing()
                }
                self.workoutCollectionController.index()
                self.tableView.reloadData()
            }
        })
        
    }
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutCollectionController.sectionItemCounts.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.workoutCollectionController.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workoutCollectionController.sectionItemCounts[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellItem = self.workoutCollectionController.cellItems[indexPath.section][indexPath.row]
        
        let activityName = cellItem.activityName
        let totalDistance = cellItem.totalDistance
        let startLocationName = cellItem.startLocationName
        cell.textLabel?.text = activityName + " " + startLocationName + " " + totalDistance
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellItem = self.workoutCollectionController.cellItems[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "toDetail", sender: cellItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destination = segue.destination as! DetailViewController
            let workoutController = sender as? WorkoutController
            destination.workoutController = workoutController
        }
    }
}
