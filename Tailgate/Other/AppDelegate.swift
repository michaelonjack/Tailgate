//
//  AppDelegate.swift
//  Tailgate
//
//  Created by Michael Onjack on 12/9/17.
//  Copyright © 2017 Michael Onjack. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SwipeNavigationController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Move firebase configuration to init to avoid race conditions with the database instantiation on the login page
    override init() {
        super.init()
        
        FirebaseApp.configure()
        // Allow Firebase database to work offline
        Database.database().isPersistenceEnabled = true
        
        // Global vars are lazy loaded by default so load the configuration now
        let _ = configuration
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Make navigation bar transparent
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        
        // Remove text from navigation bar
        //let BarButtonItemAppearance = UIBarButtonItem.appearance()
        //BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        
        // Determine which view controller should be initially shown
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController = UIViewController()
        
        // User is logged in, go right to profile
        if (Auth.auth().currentUser != nil) {
            let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            let tailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "TailgateViewController") as! TailgateViewController
            let newTailgateViewController = mainStoryboard.instantiateViewController(withIdentifier: "NewTailgateNavigationController") as! UINavigationController
            let mapViewController = mainStoryboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            let gamedayViewController = mainStoryboard.instantiateViewController(withIdentifier: "GamedayContainerViewController") as! GamedayContainerViewController
            
            let swipeNavigationController = SwipeNavigationController(centerViewController: profileViewController)
            swipeNavigationController.leftViewController = mapViewController
            swipeNavigationController.topViewController = gamedayViewController
            swipeNavigationController.shouldShowTopViewController = true
            swipeNavigationController.shouldShowBottomViewController = false
            
            // Determine which tailgate controller the user should see when they swipe right
            let userReference = Database.database().reference(withPath: "users/" + (Auth.auth().currentUser?.uid)!)
            userReference.keepSynced(true)
            userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                // If the user already has a tailgate, show them the controller for an existing one
                if snapshot.hasChild("tailgate") {
                    let snapshotValue = snapshot.value as! [String: AnyObject]
                    let tailgateId = snapshotValue["tailgate"] as? String ?? ""
                    let tailgateReference = Database.database().reference(withPath: "tailgates/" + tailgateId)
                    
                    tailgateReference.observeSingleEvent(of: .value, with: { (snapshot) in
                        let userTailgate = Tailgate(snapshot: snapshot)
                        tailgateViewController.tailgate = userTailgate
                        swipeNavigationController.rightViewController = tailgateViewController
                    })
                }
                
                // Else show them the controller to create a new one
                else {
                    swipeNavigationController.rightViewController = newTailgateViewController
                }
            })
            
            initialViewController = swipeNavigationController
        }
        
        // User is not logged in, go to home
        else {
            initialViewController = mainStoryboard.instantiateViewController(withIdentifier: "InitialNavigationController") as! UINavigationController
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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

