//
//  Uuid.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth


enum Uuid {

    static let service = uuid(suffix: 0x00)
    static let control = uuid(suffix: 0x01)
    static let slowNotifications = uuid(suffix: 0x02)
    static let upload = uuid(suffix: 0x03)
    static let info = uuid(suffix: 0x04)
    static let fastNotifications = uuid(suffix: 0x05)
    static let battery = uuid(suffix: 0x06)
    static let uniqueName = uuid(suffix: 0x07)
    static let uniqueId = uuid(suffix: 0x08)
    static let realtimeClock = uuid(suffix: 0x09)
    static let debugOut = uuid(suffix: 0x0A)
    static let debugIn = uuid(suffix: 0x0A)
    static let tunerCharging = uuid(suffix: 0x0B)

    static private func uuid(suffix: UInt8) -> CBUUID {
        return CBUUID(string: String(format: "ACA100%02X-F151-43C1-A6D0-AE9A9A7B7FA3", suffix))
    }

}
