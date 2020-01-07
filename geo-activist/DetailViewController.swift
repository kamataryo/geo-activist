//
//  DetailViewController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/07.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import UIKit
import HealthKit

class DetailViewController: UIViewController {
    
    var workout: HKWorkout? = nil
    var workoutName: String = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var energyBurnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        self.dateLabel?.text = formatter.string(from: self.workout!.startDate)
        
        self.workoutNameLabel?.text = self.workoutName
        self.distanceLabel?.text = String(format: "%@", workout?.totalDistance ?? "no data")
        self.energyBurnLabel?.text = String(format: "%@", workout?.totalEnergyBurned ?? "no data")
        
        
    }
}
