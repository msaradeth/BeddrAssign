//
//  BtState.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation


public enum BtState {
    case connected
    case connecting
    case failToConnect
    case disconnected
    case disconnecting
    case poweredOn
    case poweredOff
    case invalidData
    case unknown
    
    func description() -> String {
        switch self {
        case .connected:
            return "Bluetooth: connected"
        case .connecting:
            return "Bluetooth: connecting"
        case .failToConnect:
            return "Bluetooth: fail to connect"
        case .disconnected:
            return "Bluetooth: disconnected"
        case .disconnecting:
            return "Bluetooth: disconnecting"
        case .poweredOn:
            return "Bluetooth: poweredOn"
        case .poweredOff:
            return "Bluetooth: poweredOff"
        case .invalidData:
            return "Invalid data"
        default:
            return ""
        }
    }
}
