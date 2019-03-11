//
//  BtCharacteristic.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/10/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth




struct BtCharacteristic {
    var uniqueName: CBCharacteristic?
    var battery: CBCharacteristic?
    var deviceInfo: CBCharacteristic?
    var uniqueId: CBCharacteristic?
    var slowNotifications: CBCharacteristic?
    
    mutating func updateDiscoverCharacteristic(characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case Uuid.uniqueName:
            uniqueName = characteristic
        case Uuid.battery:
            battery = characteristic
        case Uuid.info:
            deviceInfo = characteristic
        case Uuid.uniqueId:
            uniqueId = characteristic
        case Uuid.slowNotifications:
            slowNotifications = characteristic
        default:
            break
        }
    }
    
    func getCharacteristicUUIDs() -> [CBUUID] {
        return [Uuid.info, Uuid.battery, Uuid.uniqueName, Uuid.uniqueId, Uuid.slowNotifications]
    }
}
