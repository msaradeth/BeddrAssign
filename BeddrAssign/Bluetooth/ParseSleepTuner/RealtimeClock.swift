//
//  RealtimeClock.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

struct RealtimeClock {

    private (set) var data: Data

    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.realtimeClock)
        precondition(characteristic.value != nil)
        precondition(characteristic.value!.count == 4)
        data = characteristic.value!
    }

    init(_ date: Date) {
        var secondsSince1970 = UInt32(date.timeIntervalSince1970.rounded())
        data = Data(bytes: &secondsSince1970, count: MemoryLayout.size(ofValue: secondsSince1970))
    }

    var secondsSince1970: UInt32 { return data.uint32(atByte: 0) }

}
