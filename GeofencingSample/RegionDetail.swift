//
//  RegionDetail.swift
//  GeofencingSample
//
//  Created by Payal Gupta on 10/21/16.
//  Copyright © 2016 Infoedge Pvt. Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class RegionDetail: NSObject
{
    let regionID : String
    let regionName : String
    let regionLocation : CLLocationCoordinate2D
    
    init(dict : [String : Any])
    {
        self.regionID = dict["regionID"] as! String
        self.regionName = dict["regionName"] as! String
        self.regionLocation = CLLocationCoordinate2DMake(Double(dict["latitude"] as! String)!, Double(dict["longitude"] as! String)!)
        super.init()
    }
}
