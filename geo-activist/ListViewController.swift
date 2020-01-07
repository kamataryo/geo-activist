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
    private var workoutDateKeysArray: [String] = []
    private var sectionDateKeyDictionary: Dictionary<String, String> = [:]
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

    private func requestPermissionAlert() {
        DispatchQueue.main.async(execute: { () -> Void in
             let alert = UIAlertController(title: "ワークアウトへのアクセス権限が必要です", message: "設定 -> ヘルスケア -> データアクセスとデバイスから、GeoActivist にワークアウトのデータを読み出す権限を与えて下さい。", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
             self.present(alert, animated: true)
         })
    }
    
    private func checkPermissionStatus() -> Bool {
        var result = true
        self.readDataTypes.forEach { type in
            print(type)
            // TODO: 許可の状態を確認できるようにする
            print(self.healthKitStore.authorizationStatus(for: type))
        }
        return result
    }
    
    private func refresh() {
        self.readWorkouts({ (results, error) -> Void in
            if( error != nil ) {
                print("Error reading workouts: \(String(describing: error?.localizedDescription))")
                return;
            }

            self.workouts = results as! [HKWorkout]

            let sectionDateLabelformatter = DateFormatter()
            sectionDateLabelformatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))

            let sectionDateLabelAsSortKeyformatter = DateFormatter()
            sectionDateLabelAsSortKeyformatter.dateFormat = "YYYYMMDD"
            sectionDateLabelAsSortKeyformatter.timeZone = TimeZone.current

            self.workouts.forEach { workout in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = view.bounds
        self.tableView.dataSource = self
        view.addSubview(tableView)
        self.tableView.delegate = self

        self.healthKitStore.requestAuthorization(toShare: nil, read: self.readDataTypes) {
            (success, error) -> Void in
            if (success == false || !self.checkPermissionStatus()) {
                self.requestPermissionAlert()
            } else {
                self.refresh()
            }
        }
    }
}

extension ListViewController: UITableViewDataSource {

    // TODO: タイトルヘッダを作成し、リロードのアイコンをつける
    
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
        // TODO: レイアウトをきれいにする。2つのワードが左右に justifyContent されると嬉しい
        cell.textLabel?.text = activityName + " " + distance
        
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
            destination.workoutName = self.activityNames[workout!.workoutActivityType.rawValue]?.ja ?? "(no data)"

            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
            destination.workoutStart = formatter.string(from: workout!.startDate)
        }
    }
}
