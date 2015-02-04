//
//  BeaconStationController.swift
//  BluetoothPi
//
//  Created by qihaijun on 1/30/15.
//  Copyright (c) 2015 VictorChee. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class BeaconTransmitterController: UIViewController, CBPeripheralManagerDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    
    private var beaconRegion: CLBeaconRegion!
    private var beaconData: NSDictionary!
    private var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let uuid: NSUUID = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 1, identifier: "com.victorchee.beacon")
        
        beaconData = beaconRegion.peripheralDataWithMeasuredPower(-59)
        peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start advertising
        if !peripheralManager.isAdvertising {
            peripheralManager.startAdvertising(beaconData)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = "Beacon advertising..."
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop advertising
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = "Beacon stopped"
            })
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // Bluetooth is on
            println("Advertising")
            // Start advertising
            peripheralManager.startAdvertising(beaconData)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = "Beacon advertising..."
            })
        } else if peripheral.state == .PoweredOff {
            // Bluetooth is off
            println("Stopped")
            // Stop advertising
            peripheralManager.stopAdvertising()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.statusLabel.text = "Beacon stopped"
            })
        }
    }
}
