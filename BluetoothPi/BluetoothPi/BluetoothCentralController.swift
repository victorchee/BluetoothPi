//
//  BluetoothManager.swift
//  BluetoothPi
//
//  Created by qihaijun on 1/30/15.
//  Copyright (c) 2015 VictorChee. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothCentralController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let uuid:NSUUID = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var data: NSMutableData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil
            , options: [CBCentralManagerOptionRestoreIdentifierKey : "CentralManagerOptionRestoreIdentifier"])
    }
    
    override func viewWillDisappear(animated: Bool) {
        centralManager.stopScan()
        println("Scanning stopped")
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func scan() {
        centralManager.scanForPeripheralsWithServices([uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true)])
        println("Scanning started")
    }
    
    private func cleaup() {
        if let peripheral = discoveredPeripheral {
            // Don't do anything if we're not connected
            if peripheral.state == CBPeripheralState.Disconnected {
                return
            }
            
            // See if we war subscribed to a characteristic on the peripheral
            if !peripheral.services.isEmpty {
                for service: CBService in peripheral.services as [CBService] {
                    if !service.characteristics.isEmpty {
                        for characteristic: CBCharacteristic in service.characteristics as [CBCharacteristic] {
                            if characteristic.UUID.isEqual(uuid) {
                                if characteristic.isNotifying {
                                    // It is notifying, so unsubscribe
                                    peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                                    
                                    // And we're done
                                    return
                                }
                            }
                        }
                    }
                }
            }
            
            // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
            centralManager.cancelPeripheralConnection(peripheral)
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
    
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("central manager did update state")
        if central.state == CBCentralManagerState.PoweredOn {
            scan()
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        // Reject any where the value is above reasonable range
        if RSSI.integerValue > -15 {
            return
        }
        // Reject if the signal strength is too low to be close enough (Close is around -22dB)
        if RSSI.integerValue < -35 {
            return
        }
        
        println("Discovered \(peripheral.name) at \(RSSI)")
        
        // OK, it's in range - have we already seen it?
        if !(discoveredPeripheral?.isEqual(peripheral) != nil) {
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            discoveredPeripheral = peripheral
            
            // Connect
            central.connectPeripheral(peripheral, options: nil)
            println("Connecting to peripheral \(peripheral)")
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to connect to \(peripheral). (\(error.localizedDescription))")
        cleaup()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("peripheral connected")
        
        // Stop scanning
        centralManager.stopScan()
        println("Scanning stopped")
        
        // Clear the data that we may already have
        data?.length = 0
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([uuid])
    }
    
    func centralManager(central: CBCentralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
        let peripherals: AnyObject? = dict[CBCentralManagerRestoredStatePeripheralsKey]
    }
    
    // MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error != nil {
            println("Error discovering services: \(error.localizedDescription)")
            cleaup()
            return
        }
        
        // Discover the characteristic we want
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for service in peripheral.services {
            println("Discovered service %@", service)
            
            peripheral.discoverCharacteristics([uuid], forService: service as CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        // Deal with errors if any
        if error != nil {
            println("Error discovering characteristics: \(error.localizedDescription)")
            cleaup()
            return
        }
        
        // Again, we loop through the array, jast in case
        for characteristic in service.characteristics {
            println("Discovered characteristic %@", characteristic)
            // And check if it's the right one
            if characteristic.uuid.isEqual(uuid) {
                // If it is, subscribe to it
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
            }
            
            // Once this is complete, we just need to wait for the data to come in.
            
//            peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        // Deal with errors if any
        if error != nil {
            println("Error updating characteristics: \(error.localizedDescription)")
            return
        }
        
        let data: NSData = characteristic.value
        
        // Cancel our subscription to the characteristic
        peripheral.setNotifyValue(false, forCharacteristic: characteristic)
        // Disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
        
//        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        let data: NSData = characteristic.value
        // parse the data as needed
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println(error.localizedDescription)
    }
}
