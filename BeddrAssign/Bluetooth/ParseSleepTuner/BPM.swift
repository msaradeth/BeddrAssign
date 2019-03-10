//
//  BPM.swift
//  Beddr
//
//  Created by SAJAN SHETTY on 6/8/18.
//  Copyright © 2018 STRV. All rights reserved.
//      
import Foundation
import CoreBluetooth

enum BPM {
    
    case unknown
    case sensorSaturated(SlowNotification.Flags)
    case outOfRange(Double)
    case normal(Double)
    
    var percents: Double? {
        switch self {
            case .normal(let percents): return percents
            default: return nil
        }
    }
    
    init() {
        self = .unknown
    }
    
    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.slowNotifications)
        let notification    = SlowNotification(characteristic)
        let percentage      = Double(notification.pulse)
        self                = .normal(percentage)
    }
    
    
}
