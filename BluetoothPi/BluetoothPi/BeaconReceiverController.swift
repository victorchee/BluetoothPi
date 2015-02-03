//
//  BeaconReceiver.swift
//  BluetoothPi
//
//  Created by qihaijun on 1/30/15.
//  Copyright (c) 2015 VictorChee. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconReceiverController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        let uuid:NSUUID = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.victorchee.beacon")
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        
//        locationManager.startMonitoringForRegion(beaconRegion)
//        locationManager.stopMonitoringForRegion(beaconRegion)
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
            
            let nearestBeacon: CLBeacon = beacons.first as CLBeacon
            println("nearest uuid = \(nearestBeacon.proximityUUID)\nnearest major = \(nearestBeacon.major)\nnearest minor = \(nearestBeacon.minor)")
            switch nearestBeacon.proximity {
            case CLProximity.Unknown :
                println("Beacon proximity unknown")
            case .Far :
                println("Beacon proximity far")
            case .Near :
                println("Beacon proximity near")
            case .Immediate :
                println("Beacon proximity immediate")
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = nearestBeacon.proximityUUID.UUIDString
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = nil
            })
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if region.isKindOfClass(CLBeaconRegion) {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Will enter region"
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
            
            locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region.isKindOfClass(CLBeaconRegion) {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Will exit region"
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
            
            locationManager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
}
