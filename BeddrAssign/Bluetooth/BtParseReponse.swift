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


// Parse and emit reponses to interested subscribers
// Owned by BluetoothManager
class BtParseReponse {
    private var btService: BluetoothService?
    private var subject: BluetoothSubject? {
        return btService?.subject
    }
    private var sendCommand: SendCommand?
    
    init(btService: BluetoothService, sendCommand: SendCommand?) {
        self.btService = btService
        self.sendCommand = sendCommand
    }
    
    func updateValueForCharacteristic(characteristic: CBCharacteristic) {
        guard let subject = self.subject else { return }
        
        switch characteristic.uuid {
        case Uuid.uniqueName:
            subject.uniqueName.onNext(DeviceName(characteristic: characteristic).name)
            print("[BEDDR][parsing uniqueName]")
            
        case Uuid.uniqueId:
            let uniqueId = UniqueID(characteristic: characteristic).id
            subject.uniqueId.onNext(uniqueId)
            print("[BEDDR][parsing uniqueId]")
            
        case Uuid.slowNotifications:
            guard let percents = BPM(characteristic).percents else { return }
            subject.slowNotifications.onNext(String(percents))
            print("[BEDDR][parsing slowNotifications]  \(String(percents))")
            
        case Uuid.battery:
            subject.battery.onNext(Battery(characteristic: characteristic).description)
            
        case Uuid.info:
            subject.tunDevice.onNext(Version(characteristic).fwString)
            print("[BEDDR][parsing fwString]")
            
        default:
            break
        }
        
        //Don't need at this time
        //Can also store the response to sendCommand.response rather than emiting using subjects in BluetoothManager
//        sendCommand?.emitEvent(cmdStatus: .completed)
    }
}
