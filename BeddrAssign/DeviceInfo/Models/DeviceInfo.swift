//
//  DeviceInfo.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth

struct DeviceInfo {
    var name:String
    var uuidString: String {
        return peripheral?.identifier.uuidString ?? ""
    }
    var peripheral: CBPeripheral?
    
    init(name: String, peripheral: CBPeripheral? = nil) {
        self.name = name
        self.peripheral = peripheral
    }
    
}
