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
    var deviceService: DeviceService
    var subject: BluetoothSubject? {
        return btService?.subject
    }
    var btCharacteristic: BtCharacteristic? {
        return btService?.btCharacteristic
    }
        
    
    init(btService: BluetoothService?, deviceService: DeviceService) {
        self.btService = btService
        self.deviceService = deviceService
    }
    
    // Read values for selected characteristics
    func readDeviceValues() {
        deviceService.readValues()
    }
    
    // Toggles notification
    func toggleNotification(characteristic: CBCharacteristic?)  {
        deviceService.toggleNotification(characteristic: characteristic)
    }

  
    deinit {
        print("DetailViewModel deinit")
    }
}
