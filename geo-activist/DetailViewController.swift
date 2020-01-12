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
import Mapbox

class DetailViewController: UIViewController {
    
    var workoutController: WorkoutController? = nil
    private let healthKitStore: HKHealthStore = HKHealthStore()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var energyBurnLabel: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let styleURL = URL(string: "https://raw.githubusercontent.com/geolonia/styles.geolonia.com/master/geolonia-basic/style.json")

        let mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        //        self.dateLabel?.text = self.workoutController!.startDate
        //        self.workoutNameLabel?.text = self.workoutController!.activityName
        //        self.distanceLabel?.text = String(format: "%@", workout?.totalDistance ?? "データなし")
        //        self.energyBurnLabel?.text = String(format: "%@", workout?.totalEnergyBurned ?? "データなし")
        
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
}
