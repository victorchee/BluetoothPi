//
//  BluetoothPeripheralController.swift
//  BluetoothPi
//
//  Created by Victor Chee on 15/1/30.
//  Copyright (c) 2015年 VictorChee. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothPeripheralController: UIViewController, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var dataToSend: NSData!
    var sendDataIndex: Int = 0
    var sendingEOM = false
    let notifyMTU: Int = 20
    let uuid: CBUUID = CBUUID(string: "3D27FA6E-03D5-4002-8A45-084ABEE65E84")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : uuid])
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Don't keep it going while we're not showing
        peripheralManager.stopAdvertising()
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func sendData() {
        // First up, check if we're meant to be sending an EOM
        if sendingEOM {
            // send it
            let didSend = peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            if didSend {
                sendingEOM = false
                println("Sent: EOM")
            }
            
            // if it didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscripbers to call sendData agin
            return
        }
        
        // We're not sending an EOM, so we're sending data
        // Is there any left to send?
        if sendDataIndex >= dataToSend.length {
            // No data left. Do nothing
            return
        }
        
        // There's data left, so send until the callback fails, or we're done.
        var didSend = true
        
        while didSend {
            // Make the next chunk
            // Work out how big it should be
            var amountToSend = dataToSend.length - sendDataIndex
            // Can't be longer than 20 bytes
            if amountToSend > notifyMTU {
                amountToSend = notifyMTU
            }
            // Copy out the data we want
            let chunk = NSData(bytes: dataToSend.bytes + sendDataIndex, length: amountToSend)
            // Send it
            didSend = peripheralManager.updateValue(chunk, forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
            
            // If it didn't work, drop out and wait for the callback
            if !didSend {
                return
            }
            
            let stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            println("Sent: \(stringFromData)")
            
            // It did send, so update our index
            sendDataIndex += amountToSend
            
            // Was it the last one?
            if sendDataIndex >= dataToSend.length {
                // It was - send an EOM
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                
                // Send it
                let eomSent = peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), forCharacteristic: transferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent {
                    // It sent, we're all done
                    sendingEOM = false
                    println("Sent: EOM")
                }
                
                return
            }
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
            // We're in PoweredOn state...
            println("Peripheral manager powered on.")
            // so build our service
            transferCharacteristic = CBMutableCharacteristic(type: uuid, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            let transferService = CBMutableService(type: uuid, primary: true)
            // Add the characteristic to the service
            transferService.characteristics = [transferCharacteristic]
            // And add it to the peripheral manager
            peripheralManager.addService(transferService)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("Central subscribed to characteristic");
        
        // Get the data
        dataToSend = "EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        // Reset the index
        sendDataIndex = 0
        // Start sending
        sendData()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        println("Central unsubscribed from characteristic")
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        // Start sending again
        sendData()
    }
}
