//
//  WorkoutCollectionController.swift
//  geo-activist
//
//  Created by 鎌田遼 on 2020/01/10.
//  Copyright © 2020 鎌田遼. All rights reserved.
//

import Foundation
import HealthKit

class WorkoutCollecitonController {
    private var workoutControllers: [WorkoutController] = []
    private var dateSectionTitleFormatter = DateFormatter()
    private var dateSectionSortKeyFormatter = DateFormatter()
         
    public var sectionTitles: [String] = []
    public var sectionItemCounts: [Int] = []
    public var cellItems: [[WorkoutController]] = []
    init() {
        dateSectionTitleFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        dateSectionSortKeyFormatter.dateFormat = "yyyyMMdd"
        dateSectionSortKeyFormatter.timeZone = TimeZone.current
    }
        
    public func append(workout: HKWorkout) {
        self.workoutControllers.append(WorkoutController(workout: workout))
    }
    
    public func index() {
        var dateGroups = Dictionary<String, [WorkoutController]>()
        var sectionTitleMap = Dictionary<String, String>()
        
        self.workoutControllers.forEach { workoutController in
            let dateSectionSortKey = dateSectionSortKeyFormatter.string(from: workoutController.startDate)
            if dateGroups[dateSectionSortKey] == nil {
                dateGroups[dateSectionSortKey] = [workoutController]
                sectionTitleMap[dateSectionSortKey] = dateSectionTitleFormatter.string(from: workoutController.startDate)
            } else {
                dateGroups[dateSectionSortKey]!.append(workoutController)
            }
        }
        dateGroups.keys.forEach { key in
            dateGroups[key] = dateGroups[key]!.sorted(by: { $0.startDate > $1.startDate })
        }
        
        // for table compatibility
        let sortedKeys = dateGroups.keys.sorted(by: >)
        self.sectionTitles = sortedKeys.map { key in return sectionTitleMap[key]! }
        self.sectionItemCounts = sortedKeys.map { key in return dateGroups[key]!.count }
        self.cellItems = sortedKeys.map { key in return dateGroups[key]! }
    }
    
    public func clear() {
        self.workoutControllers = []
    }
}
