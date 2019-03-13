//
//  TunDevice.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth

// Contains device discovered
struct TunDevice {
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
