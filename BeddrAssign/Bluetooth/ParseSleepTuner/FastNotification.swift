//
//  FastNotification.swift
//  Beddr
//
//  Created by Milan Rada on 18.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

struct FastNotification {

    
    var isEmpty: Bool

    var fastNotificationType: FastNotificationType = .unknown
    private let data: Data


    private var red_signal_red_ambient: [UInt8] = []
    var red_signal: Float32?

    private var red_ambient_array: [UInt8] = []
    var red_ambient: Float32?

    private var ir_signal_ir_ambient: [UInt8] = []
    var ir_signal: Float32?

    private var ir_ambient_array: [UInt8] = []
    var ir_ambient: Float32?

    var accelerationX: Int16?
    var accelerationY: Int16?
    var accelerationZ: Int16?


    init() {
        data = Data()
        isEmpty = true
    }
    
    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.fastNotifications)
        precondition(characteristic.value != nil)
        data = characteristic.value!

        isEmpty = false
        fastNotificationType = .afe

        if Int(data[0]) == FastNotificationType.afe.value {
            fastNotificationType = .afe

            for byteIndex in 2...5 {
                red_signal_red_ambient.append(data[byteIndex])
            }
            memcpy(&red_signal, red_signal_red_ambient, 4)

            for byteIndex in 6 ... 9 {
                red_ambient_array.append(data[byteIndex])
            }
            memcpy(&red_ambient, red_ambient_array, 4)

            for byteIndex in 10 ... 13 {
                red_ambient_array.append(data[byteIndex])
            }
            memcpy(&ir_signal, ir_signal_ir_ambient, 4)

            for byteIndex in 14 ... 17 {
                red_ambient_array.append(data[byteIndex])
            }
            memcpy(&ir_ambient, ir_ambient_array, 4)

        }

        if Int(data[0]) == FastNotificationType.accel.value {

            fastNotificationType = .accel

            accelerationX = Int16(data.int16(atByte: 2))
            accelerationY = Int16(data.int16(atByte: 4))
            accelerationZ = Int16(data.int16(atByte: 6))
        }
    }
}

public enum FastNotificationType: Int {
    case afe = 0
    case accel = 1
    case unknown = 2

    var value: Int {
        return self.rawValue
    }
}
