//
//  SlowNotification.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

struct SlowNotification {

    private let data: Data
    var accelerationX: Int16 { return data.int16(atByte: 0) }
    var accelerationY: Int16 { return data.int16(atByte: 2) }
    var accelerationZ: Int16 { return data.int16(atByte: 4) }
    var flags: Flags { return Flags(rawValue: data[6]) }
    var bloodOxygen: Float32 { return data.float32(atByte: 7) }
    var pulse: UInt8 { return data[11] }
    var timestamp: UInt32 { return data.uint32(atByte: 12) }

    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.slowNotifications)
        precondition(characteristic.value != nil)
        precondition(characteristic.value!.count == 16)
        data = characteristic.value!
        //Utils.calculatePosition(accX: Double(accelerationX),accY: Double(accelerationY), accZ: Double(accelerationZ))
    }

    // We skip FixedWidthInteger.init(littleEndian:) since both platforms are little-endian


    struct Flags: OptionSet {

        let rawValue: UInt8

        static let accelerationExceeded =    Flags(rawValue: 1 << 0)
        static let sidePositionDetected =    Flags(rawValue: 1 << 1)
        static let backPositionDetected =    Flags(rawValue: 1 << 2)
        static let irLowThreshold =          Flags(rawValue: 1 << 3)
        static let irUpperThreshold =        Flags(rawValue: 1 << 4)
        static let redLowThreshold =         Flags(rawValue: 1 << 5)
        static let redUpperThreshold =       Flags(rawValue: 1 << 6)
        static let uprightPositionDetected = Flags(rawValue: 1 << 7)

        var accelerometerFlags: Flags { return intersection([.accelerationExceeded, .sidePositionDetected, .backPositionDetected, .uprightPositionDetected]) }

        var oximeterFlags: Flags { return intersection([.irLowThreshold, .irUpperThreshold, .redLowThreshold, .redUpperThreshold]) }

    }

}
