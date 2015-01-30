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

class BeaconStationController: UIViewController, CBPeripheralManagerDelegate {

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var beaconRegion: CLBeaconRegion
    var beaconData: NSDictionary
    var peripheralManager: CBPeripheralManager
    
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
    
    // MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            // Bluetooth is on
            println("Broadcasting")
            // Start boradcasting
            peripheralManager.startAdvertising(beaconData)
        } else if peripheral.state == .PoweredOff {
            // Bluetooth is off
            println("Stopped")
        }
    }
}
