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
    case unknown
    
    func description() -> String {
        switch self {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .failToConnect:
            return "Fail To Connect"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        default:
            return "Not Connected To Bluetooth"
        }
    }
}
