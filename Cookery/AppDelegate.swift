//
//  AppDelegate.swift
//  Cookery
//
//  Created by Nicole Crawford on 2/27/17.
//  Copyright © 2017 Nicole Crawford. All rights reserved.
//
// Notifications based off of https://useyourloaf.com/blog/local-notifications-with-ios-10/

import CoreData
import UIKit
import MapKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var cache: NSCache<AnyObject, AnyObject> = NSCache()
    
    func scheduleNotification(forMeal meal: Meal) {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year,.month,.day,.hour,.minute,], from: meal.date as! Date)
        components.second = 0

        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Meal Reminder"
        notificationContent.body = "Time to cook \(meal.name!)!"
        notificationContent.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "\(meal.name!)Reminder", content: notificationContent, trigger: trigger)
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil { print("Couldn't add request: \(error!)") }
        }
    }
    
    func scheduleNotification(in region: CLRegion) {
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Groceries Reminder"
        notificationContent.body = "Don't forget to buy ingredients for your next meal!"
        notificationContent.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "locationReminder", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["locationReminder"])
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil { print("Couldn't add request: \(error!)") }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (accepted, error) in
            if !accepted { print(error ?? "No access to notifications.") }
        }
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Cookery")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

