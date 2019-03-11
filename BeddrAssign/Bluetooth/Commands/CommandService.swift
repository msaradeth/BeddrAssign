//
//  CommandManager.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift

protocol CommandService {
    var subjectCmdStatus: PublishSubject<CommandStatus> { get set }
    var outBuffer: Data { get set }
    var numberOfSeconds: Double { get set }
    var numberOfAttempt: Int { get set }
    var cmdStatus: CommandStatus { get set }
    var src: String { get set }
    
    func doRetry() -> Bool
    func timedout() -> Bool
    func decrementNumberOfAttempt()
    func emitError(cmdStatus: CommandStatus)
    func emitCompleted()
    func cancelTask()
}

enum CommandStatus: Error {
    case pending
    case completed
    case failed
    case timedout
    case parseError
    case cancel
}


enum CommandName: UInt8 {
    case uniqueName = 7
    case deviceInfo = 4
    case uniqueId = 8

    var payload: Data {
        let rawValues =  [rawValue]
        return Data(bytes: rawValues)
    }
}


class SendCommand: CommandService {
    var subjectCmdStatus: PublishSubject<CommandStatus>
    var outBuffer: Data
    var numberOfSeconds: Double
    var numberOfAttempt: Int
    var cmdStatus: CommandStatus
    var src: String
    
    init(outBuffer: Data, numberOfAttempt: Int = 1, numberOfSeconds: Double = 5, src: String = "") {
        self.outBuffer = outBuffer
        self.numberOfAttempt = numberOfAttempt
        self.numberOfSeconds = numberOfSeconds
        self.src = src
        self.cmdStatus = .pending
        subjectCmdStatus = PublishSubject<CommandStatus>()
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
    
    func emitError(cmdStatus: CommandStatus) {
        self.cmdStatus = cmdStatus
        numberOfAttempt = 0
        subjectCmdStatus.onError(cmdStatus)
    }
    
    func emitCompleted() {
        self.cmdStatus = .completed
        numberOfAttempt = 0
        subjectCmdStatus.onError(cmdStatus)
    }
    
    func cancelTask() {
        numberOfAttempt = 0
        cmdStatus = .cancel
        subjectCmdStatus.onCompleted()
    }
}


//var bytesData = [UInt8] (cmd.utf8)
//let writeData = Data(bytes: &bytesData, count: bytesData.count)
//var payload: Data {
//    let rawValues =  [rawValue]
//    return Data(bytes: rawValues)
//}
