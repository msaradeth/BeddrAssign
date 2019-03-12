//
//  SendRequest.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth


protocol CommandService {
    var subject: PublishSubject<CommandStatus> { get set }
    var data: Data { get set }
    var numberOfSeconds: Double { get set }
    var numberOfAttempt: Int { get set }
    var cmdStatus: CommandStatus { get set }
    var src: String { get set }
    var response: AnyObject? { get set }  //Can also store the response her rather than publishing it using subjects in BluetoothManager (another design option)
    
    func doRetry() -> Bool
    func timedout() -> Bool
    func decrementNumberOfAttempt()
    func emitEvent(cmdStatus: CommandStatus)
    func cancelTask()
}


class SendCommand: CommandService {
    var subject: PublishSubject<CommandStatus>
    var characteristic: CBCharacteristic?
    var data: Data
    var numberOfSeconds: Double
    var numberOfAttempt: Int
    var cmdStatus: CommandStatus
    var src: String
    var response: AnyObject?
    var dataToString: String {
        return String(decoding: data, as: UTF8.self)
    }
    
    init(data: Data, characteristic: CBCharacteristic?, numberOfAttempt: Int = 2, numberOfSeconds: Double = 5, src: String = "") {
        self.data = data
        self.characteristic = characteristic
        self.numberOfAttempt = numberOfAttempt
        self.numberOfSeconds = numberOfSeconds
        self.src = src
        self.cmdStatus = .pending
        subject = PublishSubject<CommandStatus>()
    }
    
    func doRetry() -> Bool {
        return cmdStatus == .pending && numberOfAttempt >  0
    }
    
    func timedout() -> Bool {
        return cmdStatus == .pending && numberOfAttempt == 0
    }
    
    func decrementNumberOfAttempt() {
        numberOfAttempt = numberOfAttempt - 1
    }
    
    func emitEvent(cmdStatus: CommandStatus) {
        self.cmdStatus = cmdStatus
        numberOfAttempt = 0
        if cmdStatus == .completed {
            subject.onCompleted()
        }else {
            subject.onError(cmdStatus)
        }
    }
    
    func cancelTask() {
        numberOfAttempt = 0
        cmdStatus = .cancel
        subject.onCompleted()
    }
}


//var bytesData = [UInt8] (cmd.utf8)
//let writeData = Data(bytes: &bytesData, count: bytesData.count)
//var payload: Data {
//    let rawValues =  [rawValue]
//    return Data(bytes: rawValues)
//}
