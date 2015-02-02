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
    @IBOutlet weak var statusLabel: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        let uuid:NSUUID = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.victorchee.beacon")
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        
//        locationManager.stopMonitoringForRegion(beaconRegion)
//        locationManager.stopRangingBeaconsInRegion(beaconRegion)
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
        if !beacons.isEmpty {
            println("Beacons found")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = "Beacons found"
            })
            
            let nearestBeacon: CLBeacon = beacons.first as CLBeacon
            println("nearest uuid = \(nearestBeacon.proximityUUID)\nnearest major = \(nearestBeacon.major)\nnearest minor = \(nearestBeacon.minor)")
            
            for beacon in beacons {
                let uuid = beacon.proximityUUID
                let major = beacon.major
                let minor = beacon.minor
                println("uuid = \(uuid)\nmajor = \(major)\nminor = \(minor)")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region.isKindOfClass(CLBeaconRegion) {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Will exit home"
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
        }
    }
}
