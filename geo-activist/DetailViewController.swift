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
import MapKit

class DetailViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    var workoutController: WorkoutController? = nil
    private let healthKitStore: HKHealthStore = HKHealthStore()
    
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var geoJsonExportButton: UIButton!
    @IBOutlet weak var descriptionTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.exportButton.addTarget(self, action: #selector(self.shareCSV), for: .touchUpInside)
        self.geoJsonExportButton.addTarget(self, action: #selector(self.shareGeoJSON), for: .touchUpInside)
        self.mapView.delegate = self
        
        if(self.workoutController!.workoutRoute != nil) {
            self.workoutController!.getAllLocations(locationExportType: .geoJSON, completion: { (geoJSONString, _) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    let polyline = self.workoutController!.polyline
                    self.mapView.addOverlay(polyline)
                    self.mapView.visibleMapRect = polyline.boundingMapRect
                });
            })
        }
    }
    
    @objc func shareCSV() {
        self.buttonEvent(locationExportType: .csv)
    }
    
    @objc func shareGeoJSON() {
        buttonEvent(locationExportType: .geoJSON)
    }
    
    func buttonEvent(locationExportType: LocationExportType) {
        if(self.workoutController!.workoutRoute == nil) {
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "ルートが見つかりませんでした", message: "このワークアウトではルートが記録されていないようです。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            })
        } else {
            self.workoutController!.getAllLocations(locationExportType: locationExportType, completion: { (allLocations, filePath) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if(filePath == nil) {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let alert = UIAlertController(title: "不明なエラー", message: "ファイルが出力できませんでした。", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        })
                    } else {
                        let url = NSURL(fileURLWithPath: filePath!)
                        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        activityViewController.excludedActivityTypes = [.postToTwitter, .postToFacebook, .postToVimeo]
                        activityViewController.popoverPresentationController?.sourceView = self.view // prevent crash
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                });
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = .red
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        return MKOverlayRenderer()
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
