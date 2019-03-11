//
//  ControlCommand.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation

enum ControlCommand: UInt8 {

    case stopLogTransfer    = 0
    case startLogTransfer   = 1
    case clearLogs          = 2
    case clearAll           = 5
    case enableLogging      = 6
    case disableLogging     = 7
    case fillLogs           = 8
    case sleep              = 9
    case logSize            = 10
    case cancelTest         = 11
    case calibrateSkin      = 12

    var payload: Data {
        let rawValues =  [rawValue]
        return Data(bytes: rawValues)
    }

}
