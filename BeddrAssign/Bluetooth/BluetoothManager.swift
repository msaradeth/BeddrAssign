//
//  BluetoothManager.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//


import Foundation
import CoreBluetooth
import RxSwift


struct BtCharacteristic {
    var uniqueName: CBCharacteristic?
    var battery: CBCharacteristic?
    var deviceInfo: CBCharacteristic?
}

class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    // MARK: - Observer Properties
    var btCharistic: BtCharacteristic
    public var subject: BluetoothSubject
    public var btState: BtState {
        didSet {
            subject.btState.onNext(btState)
            subject.btStatus.onNext(btState.description())
        }
    }
    public var devices: [DeviceHeader] {
        didSet {
            subject.devices.onNext(devices)
        }
    }
    
    // MARK: Bluetooth Properties
    fileprivate var centralManager: CBCentralManager?
    fileprivate var characteristicInstance: CBCharacteristic?
    fileprivate var peripheralInstance: CBPeripheral?
    fileprivate let serviceUUID = Uuid.service
    fileprivate let characteristicUUIDs = [Uuid.control, Uuid.slowNotifications, Uuid.upload, Uuid.info, Uuid.battery, Uuid.uniqueName, Uuid.uniqueId, Uuid.realtimeClock, Uuid.debugOut, Uuid.debugIn,Uuid.tunerCharging]

    // MARK: helper properties
    fileprivate var btParseReponse: BtParseReponse!
    
    override init() {
        //Init Properties
        btState = .unknown
        devices = []
        btCharistic = BtCharacteristic()
        subject = BluetoothSubject()
        
        super.init()
        btParseReponse = BtParseReponse(btService: self)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)])
        if let centralManager = centralManager, centralManager.state == .poweredOn {
            btState = .poweredOn
            scanForPeripherals()
        }else {
            btState = .poweredOff
        }
    }
}




// MARK: - Protocol for BtSerivces
extension BluetoothManager: BluetoothService {
    
    func write(data: Data) {
        guard let peripheralInstance = self.peripheralInstance,
            let characteristicInstance = self.characteristicInstance else {
                return
        }
        peripheralInstance.writeValue(data, for: characteristicInstance, type: CBCharacteristicWriteType.withResponse)
    }
    
    func scanForPeripherals() {
        centralManager?.scanForPeripherals(withServices: [Uuid.service], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    public func stopScan() {
        guard isScanning() else { return }
        centralManager?.stopScan()
    }
    public func isScanning() -> Bool {
        return centralManager?.isScanning ?? false
    }
    public func connect(peripheral: CBPeripheral?) {
        guard let peripheralInstance = peripheral else {
            btState = .invalidData
            return
        }
        self.peripheralInstance = peripheralInstance
        centralManager?.connect(peripheralInstance, options: nil)
    }
    public func disconnect() {
        guard let peripheral = peripheralInstance else {
            btState = .invalidData
            return
        }
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}




// MARK: - CCBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            btState = .poweredOn
            scanForPeripherals()
        case .poweredOff:
            btState = .poweredOff

        default:
            break
        }
    }
    
    // "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        btState = .connected
        if isScanning() {
            stopScan()
        }
        print("didConnect peripheral:  \(String(describing: peripheral))")
        print("didConnect peripheral serviceUUID:  \(String(describing: serviceUUID))")
        
        // look for services of interest on peripheral
        peripheralInstance = peripheral
        peripheralInstance?.delegate = self
        peripheralInstance?.discoverServices([serviceUUID])
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else { return }
        if peripheralName == "SleepTun" {
            if !devices.contains(where: { $0.peripheral!.identifier == peripheral.identifier}) {
                let deviceHeader = DeviceHeader(shortName: peripheralName, peripheral: peripheral)
                print("didDiscover peripheral:  \(peripheral.name!)  \(peripheral.identifier.uuidString)")
                devices.append(deviceHeader)
            }
        }
        
        // discover what peripheral devices OF INTEREST
        // are available for this app to connect to
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            btState = .disconnected
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            btState = .failToConnect
        }

    }

}

//
////MARK: - CBCentralManagerDelegate - handles connection
//extension BluetoothManager: CBCentralManagerDelegate {
//
//    // this method is called based on
//    // the device's Bluetooth state; we can ONLY
//    // scan for peripherals if Bluetooth is .poweredOn
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//        switch central.state {
//        case .poweredOn:
//            btStatus = .poweredOn
//            scanForPeripherals()
//        case .poweredOff:
//            btStatus = .poweredOff
//            if isScanning() {
////                stopScan()
//            }
//        default:
//            _ = "central.state is default - do nothing at this time."
//        }
//    }
//
//
//    // "Invoked when a connection is successfully created with a peripheral."
//    // we can only move forwards when we know the connection
//    // to the peripheral succeeded
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        btStatus = .connected
//
//        print("didConnect peripheral:  \(String(describing: peripheral.name))")
//        print(peripheral)
//
//        // look for services of interest on peripheral
//        peripheralInstance?.discoverServices([serviceUUID])
//    }
//
//
//    // discover what peripheral devices OF INTEREST
//    // are available for this app to connect to
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        btStatus = .disconnected
//
//        //start scanning
//        centralManager?.scanForPeripherals(withServices: [serviceUUID])
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        btStatus = .failToConnect
//    }
//
//    // discover what peripheral devices OF INTEREST
//    // are available for this app to connect to
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        // store a reference to the peripheral in
//        // class instance variable
//        print("didDiscover peripheral:  \(String(describing: peripheral.name))")
//
//
//        if peripheral.name == "SleepTun" {
//            print(peripheral.name)
//            let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
//            devices.append(deviceHeader)
//            centralManager?.connect(peripheralInstance!)
////            peripheralInstance = peripheral
////            peripheralInstance?.delegate = self
////            centralManager?.stopScan()
////            centralManager?.connect(peripheralInstance!)
//        }
//
//        // stop scanning to preserve battery life;
//        // re-scan if disconnected
//
//
//        // connect to the discovered peripheral of interest
////        if persistanceDevice?.getUUID() == peripheral.identifier.uuidString && peripheral.state == .disconnected {
////            connect(peripheral: peripheral)
////        }
////        if peripheral.state == .disconnected {
////            let pairingDevice = PairingDevice(peripheral: peripheral, rssi: RSSI)
////            devices.value.append(pairingDevice)
////        }
//
//
//    }
//}
//
//
//

//MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices peripheral:  \(peripheral)")
        guard let myServices = peripheral.services?.filter({ $0==serviceUUID }) else { return }
        for service in myServices {
            peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    // confirm we've discovered characteristics
    // of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor peripheral:  \(peripheral)")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            updateDiscoverCharacteristic(characteristic: characteristic)
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("didWriteValueFor characteristice uuid: \(String(describing: characteristicInstance?.uuid))")
    }
    
    

    // MARK: Handle Bluetooth Reponses
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        btParseReponse.updateValueForCharacteristic(characteristic: characteristic)
    }
}



// MARK: BluetoothManger - Helper functions
extension BluetoothManager {
  
    func updateDiscoverCharacteristic(characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case Uuid.uniqueName:
            btCharistic.uniqueName = characteristic
        case Uuid.battery:
            btCharistic.battery = characteristic
        case Uuid.info:
            btCharistic.deviceInfo = characteristic 
        default:
            break
        }
    }        
}



