//
//  DeviceService.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/12/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth

// DeviceService - Read values and toggle characteristic notification

class DeviceService {
    var btCharacteristic: BtCharacteristic?
    var tunDevice: TunDevice
    
    init(btCharacteristic: BtCharacteristic?, tunDevice: TunDevice) {
        self.btCharacteristic = btCharacteristic
        self.tunDevice = tunDevice
    }
    
        
    // Read values for selected characteristics
    func readValues() {
        var characteristics = [CBCharacteristic]()
        if let characteristic = btCharacteristic?.uniqueId { characteristics.append(characteristic) }
        if let characteristic = btCharacteristic?.info { characteristics.append(characteristic) }
        for characteristic in characteristics {
            tunDevice.peripheral?.readValue(for: characteristic)
        }
    }
    
    // Toggles notification
    func toggleNotification(characteristic: CBCharacteristic?)  {
        guard let characteristic = characteristic else { return }
        if characteristic.isNotifying {
            tunDevice.peripheral?.setNotifyValue(false, for: characteristic)
        }else {
            tunDevice.peripheral?.setNotifyValue(true, for: characteristic)
        }
    }
}
