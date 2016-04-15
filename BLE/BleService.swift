//
//  BleService.swift
//  BLE
//
//  Created by pedoe on 2016/1/7.
//  Copyright © 2016年 NTU. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let DialogServiceUUID = CBUUID(string: "0783B03E-8535-B5A0-7140-A304D2495CB7")
let DIALOG_UUID_RX = CBUUID(string: "0783B03E-8535-B5A0-7140-A304D2495CBA")
let DIALOG_UUID_TX = CBUUID(string: "0783B03E-8535-B5A0-7140-A304D2495CB8")
let DIALOG_UUID_FLOW_CONTROL = CBUUID(string: "0783B03E-8535-B5A0-7140-A304D2495CB9")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"


class BleService:NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self

    }
    
    deinit{
        self.reset()
    }
    
    func startDiscoveringService(){
        self.peripheral?.discoverServices([DialogServiceUUID])
    }
    
    func reset(){
        if peripheral != nil{
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBleServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(peripheral:CBPeripheral, didDiscoverServices error:NSError?){

        if(peripheral != self.peripheral){
            //Wrong peripheral
            print("Wrong peripheral")
        }
        
        if(error != nil){
            return
        }
        
        if((peripheral.services == nil) || (peripheral.services!.count == 0)){
            print("No service")
            return
        }
        
        for service in peripheral.services!{
            print("\(service)")
            if service.UUID == DialogServiceUUID{
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if(peripheral != self.peripheral){
            //Wrong peripheral
            print("Wrong peripheral")
        }
        
        if (error != nil) {
            return
        }
        
        if let characteristics = service.characteristics{
            for characteristic in characteristics{
                if characteristic.UUID == DIALOG_UUID_RX{
                    self.writeCharacteristic = (characteristic)
                 
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBleServiceNotificationWithIsBluetoothConnected(true)
                    print("Find DIALOG_UUID_RX")
                }
                else if characteristic.UUID == DIALOG_UUID_TX{
                    self.writeCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    
                    print("Find DIALOG_UUID_TX")
                }
                else if characteristic.UUID == DIALOG_UUID_FLOW_CONTROL{
                    self.writeCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    
                    print("Find DIALOG_UUID_FLOW_CONTROL")
                }
                
            }
        }
    }
    
    // Mark: - Private
    
    func writePosition(position:UInt8){
        /******** (1) CODE TO BE ADDED *******/
    }
    
    func sendBleServiceNotificationWithIsBluetoothConnected(isBluetoothconnected:Bool){
        let connectionDetails = ["isConnected": isBluetoothconnected]
    
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
}