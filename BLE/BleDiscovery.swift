//
//  BleDiscovery.swift
//  BLE
//
//  Created by pedoe on 2016/1/7.
//  Copyright © 2016年 NTU. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol bleDiscoveryProtocol{
    func didFindPeripherals(peripherals:NSMutableArray)
    func didConnectPeripherals(connectPeripheral:CBPeripheral)
}

let btDiscoverySharedInstance = BleDiscovery();

class BleDiscovery:NSObject, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager?
    private var peripheralBLE: CBPeripheral?
    private var scanPeripherals: NSMutableArray = []
    
    var bleDiscoveryDelegate:bleDiscoveryProtocol?
    
    override init() {
        super.init()
        let centralQueue = dispatch_queue_create("com.raywenderlich", DISPATCH_QUEUE_SERIAL)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanning(){
        if let central = centralManager{
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    var bleService:BleService?{
        didSet{
            if let service = self.bleService{
                service.startDiscoveringService()
            }
        }
    }
    
    // MARK: - CBCentralDelegate
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        // Be sure to retain the peripheral or it will fail during connection.
       
        //validate peripheral information
        if((peripheral.name == nil) || (peripheral.name == "")){
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if((peripheralBLE == nil) || peripheralBLE?.state == CBPeripheralState.Disconnected){
            
            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral
            
            //Reset service
            self.bleService = nil
            
        }

        self.scanPeripherals .addObject(peripheral)
        bleDiscoveryDelegate?.didFindPeripherals(self.scanPeripherals)
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        //Create new service class
     
        //if(peripheral == self.peripheralBLE){
            self.bleService = BleService(initWithPeripheral:peripheral)
        //}
        
        bleDiscoveryDelegate?.didConnectPeripherals(peripheral)
        // Stop scanning for new devices
        central.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        // See if it was our peripheral that disconnected
        if(peripheral == self.peripheralBLE){
            self.peripheralBLE = nil
            self.bleService = nil
        }
        
        // Start scanning for new devices
        self.startScanning()
    }
    
    func connectPeripheral(UUID:String)
    {
        for p in scanPeripherals {
            if p.identifier.UUIDString == UUID{
                self.centralManager?.connectPeripheral(p as! CBPeripheral, options: nil)
            }
        }
    }
    
    // MARK: Private
    
    func clearDevices(){
        self.bleService = nil
        self.peripheralBLE = nil
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state){
        
        case CBCentralManagerState.PoweredOff:
            self.clearDevices()
            
        case CBCentralManagerState.Unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            print("This iOS device does not supprt BLE")
            break
        
        case CBCentralManagerState.Unknown:
            //Wait for another event
            break
            
        case CBCentralManagerState.PoweredOn:
            self.startScanning()
            
        case CBCentralManagerState.Resetting:
            self.clearDevices()

        case CBCentralManagerState.Unsupported:
            print("The platform does not support BLE")
            break
            
        }
    }
    
    
}