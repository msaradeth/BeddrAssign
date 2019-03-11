//
//  BtParseReponse.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/10/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

class BtParseReponse {
    private var btService: BluetoothService?
    private var subject: BluetoothSubject? {
        return btService?.subject
    }
    private var cmdService: CommandService
    
    init(btService: BluetoothService, cmdService: CommandService) {
        self.btService = btService
        self.cmdService = cmdService
    }
    
    func updateValueForCharacteristic(characteristic: CBCharacteristic) {
        guard let subject = self.subject else { return }
        
        switch characteristic.uuid {
        case Uuid.uniqueName:
            subject.uniqueName.onNext(DeviceName(characteristic: characteristic).name)
            cmdService.emitCompleted()
            print("[BEDDR][parsing uniqueName]")
            
        case Uuid.uniqueId:
            let uniqueId = UniqueID(characteristic: characteristic).id
            subject.uniqueId.onNext(uniqueId)
            cmdService.emitCompleted()
            print("[BEDDR][parsing uniqueId]")
            
        case Uuid.slowNotifications:
            guard let percents = BPM(characteristic).percents else { return }
            subject.slowNotifications.onNext(String(percents))
            cmdService.emitCompleted()
            print("[BEDDR][parsing slowNotifications]  \(String(percents))")
            
        case Uuid.battery:
            subject.battery.onNext(Battery(characteristic: characteristic).description)
            cmdService.emitCompleted()
//            print("[BEDDR][parsing battery]")
            
        case Uuid.info:
            subject.deviceInfo.onNext(Version(characteristic).fwString)
            cmdService.emitCompleted()
            print("[BEDDR][parsing fwString]")
            
        default:
            break
        }
    }
}
