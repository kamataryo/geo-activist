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
    private var initialyLoaded = false
    
    private var noItems: Bool {
        return self.initialyLoaded && self.workoutCollectionController.sectionItemCounts.count == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // availability and Authorization
        if (!HKHealthStore.isHealthDataAvailable()) {
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "アプリを利用できません", message: "このデバイスではヘルスケアの機能が利用できないようです。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            })
        } else {
            self.healthKitStore.requestAuthorization(toShare: nil, read: self.readDataTypes) {
                (success, error) -> Void in
                
                DispatchQueue.main.sync(execute: { () -> Void in
                    // views
                    self.tableView.frame = self.view.bounds
                    self.tableView.dataSource = self
                    self.view.addSubview(self.tableView)
                    self.tableView.delegate = self
                    
                    // pull to refresh
                    self.refreshControl.attributedTitle = NSAttributedString(string: "下にスワイプして更新")
                    self.refreshControl.addTarget(self, action: #selector(self.pullToRefresh(_:)), for: .valueChanged)
                    self.tableView.addSubview(self.refreshControl)
                })
                
                // Ready!
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
                    self.workoutCollectionController.append(workout: workout, done: group.leave)
                }
            }
            
            group.notify(queue: .main) {
                print("notify")
                self.workoutCollectionController.index()
                self.initialyLoaded = true
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
}

extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.noItems) {
            return 1
        } else {
            return self.workoutCollectionController.sectionItemCounts.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.noItems) {
            return "ワークアウトがありません"
        } else {
            return self.workoutCollectionController.sectionTitles[section]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.noItems) {
            return 0
        } else {
            return self.workoutCollectionController.sectionItemCounts[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if(self.noItems) {
            return cell
        } else {
            let cellItem = self.workoutCollectionController.cellItems[indexPath.section][indexPath.row]
            
            let activityName = cellItem.activityName
            let totalDistance = cellItem.totalDistance
            let startLocationName = cellItem.startLocationName
            cell.textLabel?.text = activityName + " " + startLocationName + " " + totalDistance
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(self.noItems) {
            let footerView = UITextView()
            footerView.text = "ワークアウトが記録されていないか、権限がありません。設定 -> ヘルスケア -> データアクセスとデバイス からワークアウトのデータを読み出す権限をアプリに与えることができます。" + "\n\n" + "ワークアウトを新しく記録した後や、権限を変更した際はこの画面を下にスワイプするとデータを更新できます。"
            return footerView
        } else {
            return nil
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!self.noItems) {
            let cellItem = self.workoutCollectionController.cellItems[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "toDetail", sender: cellItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destination = segue.destination as! DetailViewController
            let workoutController = sender as? WorkoutController
            destination.workoutController = workoutController
        }
    }
}
