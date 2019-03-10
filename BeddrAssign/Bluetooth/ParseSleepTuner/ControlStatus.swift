//
//  ControlStatus.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

struct ControlStatus {

    private var data: Data

    var isEmpty: Bool
    
    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.control)
        precondition(characteristic.value != nil)
        precondition(characteristic.value!.count == 5)
        data = characteristic.value!
        isEmpty = false

    }

    init() {
        data = Data()
        isEmpty = true
    }

    var status: Status {
        return Status(rawValue: data[0]) ?? .error
        
    }
    var bytesAvailable: UInt32 {
        return data.uint32(atByte: 1)
        
    }

    enum Status: UInt8 {
        case logTransferComplete = 2
        case logEraseComplete = 3
        case logsSize = 4
        case sleep = 5
        case enableLogging = 6
        case disableLogging = 7
        case ready = 8
        case transfering = 9
        case deleting = 10
        case userDataClearComplete = 11
        case calibrateSkin = 12
        case lowBattery = 19
        case error = 100
    }

}
