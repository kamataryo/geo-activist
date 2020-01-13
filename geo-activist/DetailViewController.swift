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

class DetailViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var workoutController: WorkoutController? = nil
    private let healthKitStore: HKHealthStore = HKHealthStore()
    
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var descriptionTableView: UITableView!
    @IBOutlet weak var mapView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.exportButton.addTarget(self, action: #selector(self.buttonEvent), for: .touchUpInside)
    }
    
    @objc func buttonEvent() {
        if(self.workoutController!.workoutRoute == nil) {
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "ルートが見つかりませんでした", message: "このワークアウトではルートが記録されていないようです。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            })
        } else {
            self.workoutController!.getAllLocations(type: .csv, completion: { (allLocations) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    let activityViewController = UIActivityViewController(activityItems: [allLocations], applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view // prevent crash
                    self.present(activityViewController, animated: true, completion: nil)
                });
            })
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "日付"
        case 1:
            return "アクティビティ"
        case 2:
            return "距離"
        case 3:
            return "消費カロリー"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = self.workoutController!.dateLabel
        case 1:
            cell.textLabel?.text = self.workoutController!.activityName
        case 2:
            cell.textLabel?.text = self.workoutController!.totalDistance
        case 3:
            cell.textLabel?.text = self.workoutController!.totalEnergyBurned
        default:
            cell.textLabel?.text = ""
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 24.0
        } else {
            return 10.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
