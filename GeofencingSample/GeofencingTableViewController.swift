//
//  GeofencingTableViewController.swift
//  GeofencingSample
//
//  Created by Payal Gupta on 10/21/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class GeofencingTableViewController: UITableViewController
{
    //MARK: Private Properties
    fileprivate let regions : [RegionDetail] = [
        RegionDetail(dict: ["regionName" : "R1", "regionID" : "1", "latitude" : "28.570317", "longitude" : "77.321820"]),
        RegionDetail(dict: ["regionName" : "R2", "regionID" : "2", "latitude" :  "28.593049",  "longitude" :  "77.397035"]),
        RegionDetail(dict: ["regionName" : "R3", "regionID" : "3", "latitude" :  "28.639069",  "longitude" :  "77.086774"]),
        RegionDetail(dict: ["regionName" : "R4", "regionID" : "4", "latitude" :  "29.097314",  "longitude" :  "77.405783"]),
        RegionDetail(dict: ["regionName" : "R5", "regionID" : "5", "latitude" :  "28.555575",  "longitude" :  "77.063642"]),
        RegionDetail(dict: ["regionName" : "R6", "regionID" : "6", "latitude" :  "28.533520",  "longitude" :  "77.210886"]),
        RegionDetail(dict: ["regionName" : "R7", "regionID" : "7",  "latitude" :  "28.524428",  "longitude" :  "77.185456"]),
        RegionDetail(dict: ["regionName" : "R8", "regionID" : "8",  "latitude" :  "28.708040",  "longitude" :  "77.211055"]),
        RegionDetail(dict: ["regionName" : "R9", "regionID" : "9",  "latitude" :  "28.614624",  "longitude" :  "77.312158"]),
        RegionDetail(dict: ["regionName" : "R10", "regionID" : "10",  "latitude" :  "28.623247",  "longitude" :  "77.120915"]),
        RegionDetail(dict: ["regionName" : "R11", "regionID" : "11",  "latitude" :  "28.642701", "longitude" : "77.224708"]),
        RegionDetail(dict: ["regionName" : "R12", "regionID" : "12",  "latitude" :  "28.625899", "longitude" : "77.234296"]),
        RegionDetail(dict: ["regionName" : "R13", "regionID" : "13",  "latitude" :  "28.652781", "longitude" : "77.192144"]),
        RegionDetail(dict: ["regionName" : "R14", "regionID" : "14",  "latitude" :  "28.657870", "longitude" : "77.142674"]),
        RegionDetail(dict: ["regionName" : "R15", "regionID" : "15",  "latitude" :  "28.641529", "longitude" : "77.120915"])
    ]
    fileprivate let regionMonitoringHandler = RegionMonitoringHandler()
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        self.stopMonitoringAllRegions()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    //MARK: Private Methods
    private func stopMonitoringAllRegions()
    {
        let monitoredRegionsSet = AppDelegate.sharedAppDelegate().locationManager?.monitoredRegions
        for region in monitoredRegionsSet as! Set<CLCircularRegion>
        {
            AppDelegate.sharedAppDelegate().locationManager?.stopMonitoring(for: region)
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate Methods
extension GeofencingTableViewController
{
    //UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.regions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "regionCell", for: indexPath)
        cell.textLabel?.text = self.regions[indexPath.row].regionName
        return cell
    }
    
    //UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.regionMonitoringHandler.checkIfMonitoringAvailableWithRegionDetail(regionDetail: regions[indexPath.row])
    }
}
