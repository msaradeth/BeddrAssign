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
    
    init(btService: BluetoothService) {
        self.btService = btService
    }
    
    func updateValueForCharacteristic(characteristic: CBCharacteristic) {
        guard let subject = self.subject else { return }
        
        switch characteristic.uuid {
        case Uuid.uniqueName:
            subject.uniqueName.onNext(DeviceName(characteristic: characteristic).name)
        case Uuid.battery:
            subject.battery.onNext(Battery(characteristic: characteristic).description)
        case Uuid.info:
            subject.deviceInfo.onNext(Version(characteristic).fwString)
        default:
            break
        }
    }
}
