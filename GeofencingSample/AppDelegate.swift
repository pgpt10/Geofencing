//
//  AppDelegate.swift
//  GeofencingSample
//
//  Created by Payal Gupta on 10/21/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    //MARK: Internal Properties
    var window: UIWindow?
    var locationManager : CLLocationManager?
    var bufferOfMonitoredRegions: [Data]{
        get{
            let userDefaults = UserDefaults.standard
            return userDefaults.array(forKey: "BufferOfMonitoredRegions") as? [Data] ?? [Data]()
        }
        set{
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "BufferOfMonitoredRegions")
            userDefaults.synchronize()
        }
    }
    
    //MARK: Static Methods
    static func sharedAppDelegate() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //MARK: Public Methods
    /// This method prints the region identifiers of all the regions that are present in the buffer
    func printBufferOfMonitoredRegions()
    {
        let bufferOfMonitoredRegions = self.bufferOfMonitoredRegions
        for regionData in bufferOfMonitoredRegions
        {
            let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as! CLCircularRegion
            print(region.identifier)
        }
    }
    
    //MARK: Private Geotification Methods
    /// This method geotify all the regions present in the buffer. It is called when the app enters the background state i.e. when applicationDidEnterBackground is called.
    private func geotifyRegionsFromBuffer()
    {
        let bufferOfMonitoredRegions = self.bufferOfMonitoredRegions
        for regionData in bufferOfMonitoredRegions
        {
            let circularRegion = NSKeyedUnarchiver.unarchiveObject(with: regionData) as!CLCircularRegion
            if !self.checkIfRegionAlreadyGeotified(regionFromBuffer: circularRegion)
            {
                AppDelegate.sharedAppDelegate().locationManager?.startMonitoring(for: circularRegion)
                print("\(circularRegion.identifier) Geotified")
            }
        }
    }
    
    /// This method checks if a region is already being monitored by the system. This method is called before startMonitoring() is going to be called on a region from buffer.startMonitoring
    ///
    /// - parameter regionFromBuffer: Region for which this checking is to be done
    ///
    /// - returns: It returns true: if the region is already being monitored by the system and false: if the region is not already being monitored by the system
    private func checkIfRegionAlreadyGeotified(regionFromBuffer : CLCircularRegion) -> Bool
    {
        let monitoredRegionsSet = AppDelegate.sharedAppDelegate().locationManager?.monitoredRegions
        for region in monitoredRegionsSet as! Set<CLCircularRegion>
        {
            if region.identifier == regionFromBuffer.identifier
            {
                return true
            }
        }
        return false
    }
    
    /// This method removes a region from the buffer.
    ///
    /// - parameter regionIdentifier: region identifier of the region which is to be removed from the buffer
    private func removeRegionFromBufferWithRegionIdentifier(regionIdentifier : String)
    {
        var bufferOfMonitoredRegions = self.bufferOfMonitoredRegions
        for regionData in self.bufferOfMonitoredRegions
        {
            let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as! CLCircularRegion
            if region.identifier == regionIdentifier
            {
                bufferOfMonitoredRegions.remove(at: self.bufferOfMonitoredRegions.index(of: regionData)!)
                break
            }
        }
        self.bufferOfMonitoredRegions = bufferOfMonitoredRegions
    }
    
    
    /// This method removes a region from the list of the regions that are already being monitored by the system itself. stopMonitoring() is called for the region we want to stop monitoring.
    ///
    /// - parameter regionIdentifier: region identifier of the region we need to stop monitoring
    fileprivate func removeRegionFromMonitoredRegionsWithRegionIdentifier(regionIdentifier : String)
    {
        let monitoredRegions = AppDelegate.sharedAppDelegate().locationManager?.monitoredRegions
        for region in monitoredRegions as! Set<CLCircularRegion>
        {
            if region.identifier == regionIdentifier
            {
                AppDelegate.sharedAppDelegate().locationManager?.stopMonitoring(for: region)
                self.removeRegionFromBufferWithRegionIdentifier(regionIdentifier: regionIdentifier)
                print("\(regionIdentifier) deleted")
                break
            }
        }
    }
    
    //MARK: Geofencing Notifications
    func application(_ application: UIApplication, didReceive notification: UILocalNotification)
    {
        if let regionIdentifier = notification.userInfo?["regionIdentifier"] as? String
        {
            //Stop Monitoring the region once the notification is received for that region.
            self.removeRegionFromMonitoredRegionsWithRegionIdentifier(regionIdentifier: regionIdentifier)
        }
    }

    //MARK: App Lifecycle Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {

    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        self.geotifyRegionsFromBuffer()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {

    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {

    }

    func applicationWillTerminate(_ application: UIApplication)
    {

    }
}

extension AppDelegate : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        let regionIdentifier = region.identifier
        let regionDescription = regionIdentifier.components(separatedBy: "_")
        let notificationString = "You are approaching near \(regionDescription.first!)"
        if UIApplication.shared.applicationState == .active
        {
            let alertController = UIAlertController(title: "Reminder", message: notificationString, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {[weak self] (action) in
                self?.removeRegionFromMonitoredRegionsWithRegionIdentifier(regionIdentifier: regionIdentifier)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(alertAction)
            alertController.addAction(cancelAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let notification = UILocalNotification()
            notification.alertBody = notificationString
            notification.alertAction = "Show me the region details."
            notification.userInfo = ["regionIdentifier" : regionIdentifier]
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        let regionIdentifier = region.identifier
        let regionDescription = regionIdentifier.components(separatedBy: "_")
        let notificationString = "You are exiting \(regionDescription.first!)"
        if UIApplication.shared.applicationState == .active
        {
            let alertController = UIAlertController(title: "Reminder", message: notificationString, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {[weak self] (action) in
                self?.removeRegionFromMonitoredRegionsWithRegionIdentifier(regionIdentifier: regionIdentifier)
                })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(alertAction)
            alertController.addAction(cancelAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let notification = UILocalNotification()
            notification.alertBody = notificationString
            notification.alertAction = "Show me the region details."
            notification.userInfo = ["regionIdentifier" : regionIdentifier]
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
}

