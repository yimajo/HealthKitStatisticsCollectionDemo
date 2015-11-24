//
//  AppDelegate.swift
//  HealthKitStatisticsCollectionDemo
//
//  Created by Yoshinori Imajo on 2015/11/24.
//  Copyright © 2015年 Yoshinori Imajo. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        healthStore.handleAuthorizationForExtensionWithCompletion { success, error in
            if let error = error where !success {
                print("The error was: \(error.localizedDescription)")
            }
        }

        return true
    }
}

