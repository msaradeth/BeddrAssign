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


protocol BluetoothService {
    var subject: BluetoothSubject { get set }
    var btState: BtState { get set }
    
    func write(data: Data)
    func scanForPeripherals()
    func stopScan()
    func isScanning()  -> Bool
    func connect(peripheral: CBPeripheral?)
    func disconnect()
}



struct BluetoothSubject {
    var btState: BehaviorSubject<BtState>
    var devices: BehaviorSubject<[DeviceHeader]>
    var uniqueName: BehaviorSubject<String>
    var battery: BehaviorSubject<String>
    var deviceInfo: BehaviorSubject<String>
    var btStatus: BehaviorSubject<String>
    
    init() {
        btState = BehaviorSubject<BtState>(value: .unknown)
        devices = BehaviorSubject<[DeviceHeader]>(value: [])
        uniqueName = BehaviorSubject<String>(value: "")
        battery = BehaviorSubject<String>(value: "")
        deviceInfo = BehaviorSubject<String>(value: "")
        btStatus = BehaviorSubject<String>(value: "")
    }
}
