//
//  BluetoothManager.swift
//  Vhista Clip
//
//  Created by Juan David Cruz Serrano on 8/4/18.
//  Copyright © 2018 Juan David Cruz Serrano. All rights reserved.
//

import Foundation
import CoreBluetooth

class VHBluetoothManager: NSObject {
    
    let BLE_UUID = CBUUID(string: "ff51b30e-d7e2-4d93-8842-a7c4a57dfb07")
    
    struct BLECharacteristics {
        static let LoadAverageUUID = CBUUID(string: "ff51b30e-d7e2-4d93-8842-a7c4a57dfb10")
        static let UptimeUUID = CBUUID(string: "ff51b30e-d7e2-4d93-8842-a7c4a57dfb09")
        static let MemoryUUID = CBUUID(string: "ff51b30e-d7e2-4d93-8842-a7c4a57dfb08")
    }
    
    var centralManager: CBCentralManager?
    var peripheralVhistaClip: CBPeripheral?
    
    // MARK: - Initialization Method
    override init() {
        super.init()
    }
    
    static let shared: VHBluetoothManager = {
        let instance = VHBluetoothManager()
        return instance
    }()
    
    
    func startMonitoring() {
        // STEP 1: create a concurrent background queue for the central
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.juandavidcruz.centralQueue", attributes: .concurrent)
        // STEP 2: create a central to scan for, connect to,
        // manage, and collect data from peripherals
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
}

extension VHBluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        case .resetting:
            print("Bluetooth status is RESETTING")
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            // STEP 3.2: scan for peripherals that we're interested in
            centralManager?.scanForPeripherals(withServices: [BLE_UUID])
            
        } // END switch
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral.name ?? "No Name on peripheral")
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        peripheralVhistaClip = peripheral
        // STEP 4.3: since HeartRateMonitorViewController
        // adopts the CBPeripheralDelegate protocol,
        // the peripheralHeartRateMonitor must set its
        // delegate property to HeartRateMonitorViewController
        // (self)
        peripheralVhistaClip?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        
        // STEP 6: connect to the discovered peripheral of interest
        centralManager?.connect(peripheralVhistaClip!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // STEP 8: look for services of interest on peripheral
        print("Did connect to peripheral \(peripheral)")
        peripheralVhistaClip?.discoverServices([BLE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager?.scanForPeripherals(withServices: [BLE_UUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == BLE_UUID {
                print("Service: \(service)")
                // STEP 9: look for characteristics of interest
                // within services of interest
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print(characteristic.value ?? "")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
    }
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        
        switch peripheralState {
        case .disconnected:
            print("Peripheral state: disconnected")
        case .connected:
            print("Peripheral state: connected")
        case .connecting:
            print("Peripheral state: connecting")
        case .disconnecting:
            print("Peripheral state: disconnecting")
        }
        
    }
    
}
