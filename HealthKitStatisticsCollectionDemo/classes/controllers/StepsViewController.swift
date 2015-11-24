//
//  StepsViewController.swift
//  HealthKitStatisticsCollectionDemo
//
//  Created by Yoshinori Imajo on 2015/11/24.
//  Copyright © 2015年 Yoshinori Imajo. All rights reserved.
//

import UIKit
import HealthKit

class StepsViewController: UITableViewController {

    private let healthStore = HKHealthStore()
    private var statisticsCollection: HKStatisticsCollection?
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestWeakStatisticsCollection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let statisticsCollection = statisticsCollection {
            return statisticsCollection.statistics().count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if let statisticsCollection = statisticsCollection {
            
            let item = statisticsCollection.statistics()[statisticsCollection.statistics().count - indexPath.row - 1]
            
            cell.textLabel?.text = "\(Int(item.sumQuantity()!.doubleValueForUnit(HKUnit.countUnit())))"
            cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(item.startDate))"
            
        }
        
        return cell
    }
}

private extension StepsViewController {
    
    /**
     現在から一週間前の日からStatisticsCollectionを取得する
     */
    func requestWeakStatisticsCollection() {
        
        // 今から一週間前
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let day = -7
        let now = NSDate()
        let today = calendar.startOfDayForDate(now)
        
        // endは今でいい
        let endDate = now
        // startはdayを今日から加算した
        let startDate = calendar.dateByAddingUnit([.Day], value: day, toDate: today, options: NSCalendarOptions.WrapComponents)!
        // 今日の始まりの0時からアンカーにしたい
        let anchorDate = today
        
        let intervalComponents = NSDateComponents()
        intervalComponents.day = 1
        
        // optionで厳密にどこで切るかを指定。startで厳密に切ってしまうと一週間前の日の今の時間からしか取得できない
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: [.None])
        let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!
        let statsOptions: HKStatisticsOptions = [HKStatisticsOptions.SeparateBySource, HKStatisticsOptions.CumulativeSum]
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: statsOptions, anchorDate: anchorDate, intervalComponents: intervalComponents)
        
        print("\(startDate)) - \(endDate)")
        print("anchorDate: \(anchorDate)")
        

        query.initialResultsHandler = { [unowned self] (query, result, error) in
            guard let result = result where error == nil else{
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statisticsCollection = result
                for item in result.statistics() {
                    print("\(item.startDate) - \(item.endDate) \(item.sumQuantity()!.doubleValueForUnit(HKUnit.countUnit()))")
                    
                }
                self.tableView.reloadData()
            })
        }
        
        healthStore.executeQuery(query)
    }

}
