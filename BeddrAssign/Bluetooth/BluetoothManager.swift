//
//  BluetoothManager.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.

import Foundation
import CoreBluetooth
import RxSwift

// Bluetooth Manager conforms to the following protocols:
// 1. BluetoothService - An interface to Bluetooth Manager module
// 2. CCBCentralManagerDelegate - client
// 3. CBPeripheralDelegate - (server/datasource)

class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    // MARK: - Observer Properties
    public var subject: BluetoothSubject
    public var btStatus: BtStatus {
        didSet {
            subject.btStatus.onNext(btStatus)
        }
    }
    public var devices: [TunDevice] {
        didSet {
            subject.devices.onNext(devices)
        }
    }
    
    // MARK: Bluetooth Properties
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheralInstance: CBPeripheral?
    fileprivate let serviceUUID = Uuid.service
    fileprivate var characteristicUUIDs: [CBUUID]

    // MARK: helper properties
    fileprivate var btParseReponse: BtParseReponse!
    internal var btCharacteristic: BtCharacteristic
    fileprivate var sendCommand: SendCommand?
    var autoConnect = false
    
    override init() {
        //Init Properties
        btStatus = .unknown
        devices = []
        btCharacteristic = BtCharacteristic()
        subject = BluetoothSubject()
        characteristicUUIDs = btCharacteristic.getCharacteristicUUIDs()
        
        super.init()
        btParseReponse = BtParseReponse(btService: self, sendCommand: sendCommand)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)])
        if let centralManager = centralManager, centralManager.state == .poweredOn {
            btStatus = .poweredOn
            scanForPeripherals()
        }else {
            btStatus = .poweredOff
        }
    }
}



// MARK: - Protocol for BluetoothService
extension BluetoothManager: BluetoothService {
    
    func write(sendCommand: SendCommand) {
        guard let peripheralInstance = self.peripheralInstance,
            let characteristic = sendCommand.characteristic,
            peripheralInstance.state == .connected else {
                return
        }
        self.sendCommand = sendCommand
        print("writing characteristic: \(characteristic.uuid)  dataString: \(sendCommand.dataToString)")
        peripheralInstance.writeValue(sendCommand.data, for: characteristic, type: CBCharacteristicWriteType.withResponse)

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
            btStatus = .invalidData
            return
        }
        self.peripheralInstance = peripheralInstance
        centralManager?.connect(peripheralInstance, options: nil)
    }
    public func disconnect() {
        guard let peripheral = peripheralInstance else {
            btStatus = .invalidData
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
            btStatus = .poweredOn
            scanForPeripherals()
        case .poweredOff:
            btStatus = .poweredOff

        default:
            break
        }
    }
    
    // discover what peripheral devices OF INTEREST are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else { return }
        //If is Sleep Tuner and not in devices list, add it to the list
//        if peripheralName == "SleepTun" {
        if !devices.contains(where: { $0.peripheral!.identifier == peripheral.identifier}) {
            let deviceHeader = TunDevice(name: peripheralName, peripheral: peripheral)
            print("didDiscover peripheral:  \(peripheral.name!)  \(peripheral.identifier.uuidString)")
            devices.append(deviceHeader)
        }
    }
    
    // "Invoked when a connection is successfully created with a peripheral."
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        btStatus = .connected
        if isScanning() {
            stopScan()
        }
        print("didConnect peripheral serviceUUID:  \(String(describing: serviceUUID))  \(String(describing: peripheral))")
        // look for services of interest on peripheral
        peripheral.delegate = self
        peripheral.discoverServices([Uuid.service])
        peripheralInstance = peripheral
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        btStatus = .disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        btStatus = .failToConnect
    }
}



//MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices peripheral:  \(peripheral)")
        guard let myServices = peripheral.services?.filter({ $0.uuid == Uuid.service }) else { return }
        for service in myServices {
            peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    // confirm we've discovered characteristics of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor peripheral:  \(peripheral)")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == Uuid.uniqueName {
                peripheral.readValue(for: characteristic)   //Read uniqueName to display on first screen
            }
            btCharacteristic.updateDiscoverCharacteristic(characteristic: characteristic)
            print("didDiscoverCharacteristicsFor characteristic:  \(characteristic)")
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == btCharacteristic.uniqueName || characteristic.uuid == btCharacteristic.info || characteristic.uuid == btCharacteristic.uniqueId {
            NSLog("didWriteValueFors characteristice uuid: \(String(describing: characteristic.uuid))")
        }
    }
    
    
    // MARK: Handle Bluetooth Reponses
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == btCharacteristic.uniqueName || characteristic.uuid == btCharacteristic.info || characteristic.uuid == btCharacteristic.uniqueId {
            NSLog("didUpdateValueFor characteristice uuid: \(String(describing: characteristic.uuid))")
        }
        btParseReponse.updateValueForCharacteristic(characteristic: characteristic)
    }
}






//            if characteristic.properties.contains(.read) && characteristic.uuid != Uuid.realtimeClock {
//                peripheral.readValue(for: characteristic)
//            }
//            if characteristic.properties.contains(.notify) {
//                peripheral.setNotifyValue(true, for: characteristic)
//            }

