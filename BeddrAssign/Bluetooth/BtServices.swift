//
//  BtServices.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift


struct BluetoothSubjects {
    var btState: BehaviorSubject<BtState>
    var devices: BehaviorSubject<[DeviceHeader]>
    var uniqueName: PublishSubject<String>
    var battery: PublishSubject<Battery>
    var deviceInfo: PublishSubject<Version>
    
    init() {
        btState = BehaviorSubject<BtState>(value: .unknown)
        devices = BehaviorSubject<[DeviceHeader]>(value: [])
        uniqueName = PublishSubject<String>()
        battery = PublishSubject<Battery>()
        deviceInfo = PublishSubject<Version>()
    }
}

protocol BtSerivces {
    var subject: BluetoothSubjects { get set }
    var btState: BtState { get set }
    
    func write(data: Data)
    func scanForPeripherals()
    func stopScan()
    func isScanning()  -> Bool
    func connect(peripheral: CBPeripheral?)
    func disconnect()
}


