//
//  BluetoothManager.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.

import Foundation
import CoreBluetooth
import RxSwift


class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    // MARK: - Observer Properties
    public var subject: BluetoothSubject
    public var btStatus: BtStatus {
        didSet {
            subject.btStatus.onNext(btStatus)
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
    fileprivate var characteristicUUIDs: [CBUUID]

    // MARK: helper properties
    fileprivate var btParseReponse: BtParseReponse!
    fileprivate var btCharacteristic: BtCharacteristic
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
            let characteristicInstance = self.characteristicInstance,
            btStatus == .connected else {
                sendCommand.emitEvent(cmdStatus: .failed)
                return
        }
        self.sendCommand = sendCommand     
        peripheralInstance.writeValue(sendCommand.data, for: characteristicInstance, type: CBCharacteristicWriteType.withResponse)
        
        //Handle retry or command timed out
        DispatchQueue.main.asyncAfter(deadline: .now() + sendCommand.numberOfSeconds) {
            if sendCommand.doRetry() {
                sendCommand.decrementNumberOfAttempt()
                self.write(sendCommand: sendCommand)
            }else if sendCommand.timedout() {
                sendCommand.emitEvent(cmdStatus: .timedout)
            }
        }
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else { return }
        //If is Sleep Tuner and not in devices list, add it to the list
        if peripheralName == "SleepTun" {
            if !devices.contains(where: { $0.peripheral!.identifier == peripheral.identifier}) {
                let deviceHeader = DeviceHeader(shortName: peripheralName, peripheral: peripheral)
                print("didDiscover peripheral:  \(peripheral.name!)  \(peripheral.identifier.uuidString)")
                devices.append(deviceHeader)
                
                if autoConnect == true {
                    connect(peripheral: peripheral)
                    autoConnect = false
                }
            }
        }
    }
    
    // "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
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
    
    // discover what peripheral devices OF INTEREST
    // are available for this app to connect to
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
    
    // confirm we've discovered characteristics
    // of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor peripheral:  \(peripheral)")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
            btCharacteristic.updateDiscoverCharacteristic(characteristic: characteristic)
            print("didDiscoverCharacteristicsFor characteristic:  \(characteristic)")
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




