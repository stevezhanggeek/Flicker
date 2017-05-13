//
//  AppDelegate.swift
//  RFDuinoLedButtonInSwift
//
//  Created by Cristian Duguet on 9/14/15.
//  Copyright (c) 2015 TrainFES. All rights reserved.
//


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var wasScanning :  Bool = false
    var rfduinoManager = RFduinoManager()
    var viewController = ScanViewController(style: .plain)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
/*
        self.window = UIWindow(frame: UIScreen.main.bounds)

        let navController: UINavigationController = UINavigationController(rootViewController: viewController)
        
        self.window!.rootViewController = navController
        
        navController.navigationBar.tintColor = UIColor.black
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()*/

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        wasScanning = false;
        
        if (rfduinoManager.isScanning() == true) {
            wasScanning = true;
            rfduinoManager.stopScan();
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}

