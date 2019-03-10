//
//  DeviceHeader.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth

struct DeviceHeader {
    var shortName:String
    var fullName: String?
    var deviceDetail: DeviceDetail?
    var peripheral: CBPeripheral?
    
    init(shortName: String, peripheral: CBPeripheral? = nil, fullName: String? = nil, deviceDetail: DeviceDetail? = nil) {
        self.shortName = shortName
        self.peripheral = peripheral
        self.fullName = fullName
        self.deviceDetail = deviceDetail
    }
    
    init(shortName: String, peripheral: CBPeripheral?) {
        self.init(shortName: shortName, peripheral: peripheral, fullName: nil, deviceDetail: nil)
    }
}
