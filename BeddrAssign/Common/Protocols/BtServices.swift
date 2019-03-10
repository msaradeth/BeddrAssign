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


typealias SubjectBtStateType = BehaviorSubject<BtState>
typealias SubjectDevicesType = BehaviorSubject<[DeviceHeader]>

protocol BtSerivces {
    var subjectBtState: SubjectBtStateType { get set }
    var subjectDevices: SubjectDevicesType { get set }
    var btState: BtState { get set }
    
    func write(data: Data)
    func scan()
    func stopScan()
    func isScanning()  -> Bool
    func connect(peripheral: CBPeripheral?)
    func disconnect()
}

