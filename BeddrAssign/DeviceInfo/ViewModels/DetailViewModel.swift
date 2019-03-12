//
//  DetailViewModel.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth

// DetailViewModel - owns BluetoothService (an interface to Bluetooth Manager)
// 1.  Toggles given characteristic notification setting
// 2.  Reads data for characteristic

class DetailViewModel {
    let bag = DisposeBag()
    var btService: BluetoothService?
    var subject: BluetoothSubject? {
        return btService?.subject
    }
    var btCharacteristic: BtCharacteristic? {
        return btService?.btCharacteristic
    }
    var deviceInfo: DeviceInfo
    
    init(btService: BluetoothService?, deviceInfo: DeviceInfo) {
        self.btService = btService
        self.deviceInfo = deviceInfo
    }
    
    // Read values for selected characteristics
    func readValues() {
        var characteristics = [CBCharacteristic]()
        if let characteristic = btCharacteristic?.uniqueId { characteristics.append(characteristic) }
        if let characteristic = btCharacteristic?.deviceInfo { characteristics.append(characteristic) }
        for characteristic in characteristics {
            deviceInfo.peripheral?.readValue(for: characteristic)
        }
    }
    
    
    // Toggles notification
    func toggleNotification(characteristic: CBCharacteristic?)  {
        guard let characteristic = characteristic else { return }
        if characteristic.isNotifying {
            deviceInfo.peripheral?.setNotifyValue(false, for: characteristic)
        }else {
            deviceInfo.peripheral?.setNotifyValue(true, for: characteristic)
        }
    }
  
    deinit {
        print("DetailViewModel deinit")
    }
}
