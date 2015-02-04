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
    var characteristic: CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // run 'uuidgen' in terminal
        let uuid: CBUUID = CBUUID(string: "3D27FA6E-03D5-4002-8A45-084ABEE65E84")
        let data: NSData = NSData()
        characteristic = CBMutableCharacteristic(type: uuid, properties: CBCharacteristicProperties.Read, value: data, permissions: CBAttributePermissions.Readable)
        var service: CBMutableService = CBMutableService(type: uuid, primary: true)
        service.characteristics = [characteristic]
        
        peripheralManager.addService(service)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.UUID]])
        
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

    // MARK: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("peripheral manager did update state")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        println(error.localizedDescription)
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        println(error.localizedDescription)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
        if request.characteristic.UUID.isEqual(characteristic.UUID) {
            println("peripheral manager did reveive read request")
            if request.offset > characteristic.value.length {
                peripheralManager.respondToRequest(request, withResult: CBATTError.InvalidOffset)
                return;
            } else {
                request.value = characteristic.value.subdataWithRange(NSMakeRange(request.offset, characteristic.value.length - request.offset))
                peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
                
            }
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        characteristic.value = (requests.first as CBATTRequest).value
        peripheralManager.respondToRequest(requests.first as CBATTRequest, withResult: CBATTError.Success)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic theCharacteristic: CBCharacteristic!) {
        let data = theCharacteristic.value
        let didSendValue: Bool = peripheralManager.updateValue(data, forCharacteristic: characteristic, onSubscribedCentrals: nil)
    }
}
