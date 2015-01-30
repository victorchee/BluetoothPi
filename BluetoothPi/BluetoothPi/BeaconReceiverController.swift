//
//  BeaconReceiver.swift
//  BluetoothPi
//
//  Created by qihaijun on 1/30/15.
//  Copyright (c) 2015 VictorChee. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconReceiver: UIViewController, CLLocationManagerDelegate {
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self;
        
        let uuid:NSUUID = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.victorchee.beacon")
        beaconRegion.notifyEntryStateOnDisplay = true
        
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        println("Beacons found")
        
        for beacon in beacons {
            let uuid = beacon.proximityUUID
            let major = beacon.major
            let minor = beacon.minor
            println("uuid = \(uuid)\nmajor = \(major)\nminor = \(minor)")
        }
    }
}
