//
//  RegionMonitoringHandler.swift
//  GeofencingSample
//
//  Created by Payal Gupta on 10/21/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class RegionMonitoringHandler: NSObject
{
    //MARK: Private Properties
    let GEOFENCE_RADIUS = 200.0 //In metres
    var regionDetail : RegionDetail!
    
    //MARK: Internal Methods
    
    /// This method: 1. checks if region monitoring is available on the device or not 2. If region monitoring is available, checks if the region corresponding to regionDetail is already present in the buffer 3. If the region is not present in the buffer, it prompts for user permission "Always Use Location Service". 4. Based in the user response, the region is then added to the buffer
    ///
    /// - parameter regionDetail: Region which is to be added to the buffer
    func checkIfMonitoringAvailableWithRegionDetail(regionDetail : RegionDetail)
    {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) //TODO:
        {
            self.regionDetail = regionDetail
            if !self.checkIfRegionAlreadyInBuffer()
            {
                AppDelegate.sharedAppDelegate().locationManager = CLLocationManager()
                AppDelegate.sharedAppDelegate().locationManager?.delegate = self
            }
        }
        else
        {
            print("Region Monitoring service is not available on your device.")
        }
    }
    
    //MARK: Private Methods
    /// This method checks if the region corresponding to regionDetail is already present in the buffer on the basis of region identifier.
    ///
    /// - returns: true: if region is already present in the buffer, false: if region is not present in the buffer
    private func checkIfRegionAlreadyInBuffer() -> Bool
    {
        let regionIdentifier = "\(self.regionDetail.regionName)_\(self.regionDetail.regionID)"
        let bufferOfMonitoredRegions = AppDelegate.sharedAppDelegate().bufferOfMonitoredRegions
        for regionData in bufferOfMonitoredRegions
        {
            let region = NSKeyedUnarchiver.unarchiveObject(with: regionData) as! CLCircularRegion
            if region.identifier == regionIdentifier
            {
                print("Region \(self.regionDetail.regionName) is already in Buffer/Geotified.")
                return true
            }
        }
        return false
    }
    
    /// This method add the region corresponding to regionDetail to the buffer.
    fileprivate func addRegionToBuffer()
    {
        let regionName = self.regionDetail.regionName
        let regionID = self.regionDetail.regionID
        let regionLocation = self.regionDetail.regionLocation
        let regionIdentifier = "\(regionName)_\(regionID)"
        
        let regionGeofence = CLCircularRegion(center: regionLocation, radius: GEOFENCE_RADIUS, identifier: regionIdentifier)
        
        var bufferOfMonitoredRegions = AppDelegate.sharedAppDelegate().bufferOfMonitoredRegions
        bufferOfMonitoredRegions.append(NSKeyedArchiver.archivedData(withRootObject: regionGeofence))
        if bufferOfMonitoredRegions.count > 10
        {
            let firstRegionFromBufferOfMonitoredRegions = NSKeyedUnarchiver.unarchiveObject(with: bufferOfMonitoredRegions.first!) as! CLCircularRegion
            bufferOfMonitoredRegions.remove(at: 0)
            print("\(firstRegionFromBufferOfMonitoredRegions.identifier) Deleted from Buffer")
            
            let monitoredRegionsSet = AppDelegate.sharedAppDelegate().locationManager?.monitoredRegions
            for regionFromSet in (monitoredRegionsSet as! Set<CLCircularRegion>)
            {
                if regionFromSet.identifier == firstRegionFromBufferOfMonitoredRegions.identifier
                {
                    AppDelegate.sharedAppDelegate().locationManager?.stopMonitoring(for: regionFromSet)
                    print("\(regionFromSet.identifier) Deleted from Monitored Regions")
                    break
                }
            }
            
        }
        AppDelegate.sharedAppDelegate().bufferOfMonitoredRegions = bufferOfMonitoredRegions
        print("Region \(regionName) added to Buffer.")
    }
}

// MARK: - CLLocationManagerDelegate Methods
extension RegionMonitoringHandler : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .notDetermined, .authorizedWhenInUse:
            AppDelegate.sharedAppDelegate().locationManager?.requestAlwaysAuthorization() //TODO:
        case .authorizedAlways:
            self.addRegionToBuffer()
        case .denied, .restricted:
            print("Your app is not permitted to use location services. Change your app settings if you want to use location services.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    {
        print(error.localizedDescription)
    }
}
