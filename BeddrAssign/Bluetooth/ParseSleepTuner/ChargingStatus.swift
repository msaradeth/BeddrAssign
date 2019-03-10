//
//  Status.swift
//  Beddr
//
//  Created by SAJAN SHETTY on 8/3/18.
//  Copyright © 2018 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

enum ChargingStatus : CustomStringConvertible {
    
    var description : String {
        switch self {
        case .unknown:
            return "unknown charging status"
        case .charging:
            return "is charging"
        case .not_charging:
            return "not charging"
        }
    }
    
    case unknown
    case charging
    case not_charging

    init(characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.tunerCharging)
        self = .unknown
        
        if let data = characteristic.value?[0] {
            switch data {
                
                case 0 :
                    self = .unknown

                case 1:
                    if(self != .charging){
                        self = .charging
                    }
                
                case 2:
                    if(self != .not_charging){
                        self = .not_charging
                    }
                
                default:
                    self = .unknown
            
            }
        }
    }
}
