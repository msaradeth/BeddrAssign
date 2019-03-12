//
//  BluetoothService.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift


// An interface to Bluetooth Manager module
// To be injected to any objects that wants to subscriber to observers or write to bluetooth
// Contains observers, characteristics, bluetooth status and other bluetooth fuctionalities
// BluetoothManager conforms to this protocol
protocol BluetoothService {
    var subject: BluetoothSubject { get set }
    var btStatus: BtStatus { get set }
    var btCharacteristic: BtCharacteristic { get set }
    
    func write(sendCommand: SendCommand)
    func scanForPeripherals()
    func stopScan()
    func isScanning()  -> Bool
    func connect(peripheral: CBPeripheral?)
    func disconnect()
}


// Observers for client (Objects or Views to subscriber to)
// Own by BluetoothService protocol  
struct BluetoothSubject {
    var btStatus: BehaviorSubject<BtStatus>
    var devices: BehaviorSubject<[DeviceInfo]>
    var uniqueName: BehaviorSubject<String>
    var battery: BehaviorSubject<String>
    var deviceInfo: BehaviorSubject<String>
    var slowNotifications: BehaviorSubject<String>
    var uniqueId: BehaviorSubject<String>
    
    init() {
        btStatus = BehaviorSubject<BtStatus>(value: .unknown)
        devices = BehaviorSubject<[DeviceInfo]>(value: [])
        uniqueName = BehaviorSubject<String>(value: "")
        battery = BehaviorSubject<String>(value: "")
        deviceInfo = BehaviorSubject<String>(value: "")
        slowNotifications = BehaviorSubject<String>(value: "")
        uniqueId = BehaviorSubject<String>(value: "")
    }
}
