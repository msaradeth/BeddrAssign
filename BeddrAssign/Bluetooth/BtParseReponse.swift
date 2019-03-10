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
    private var btServices: BtSerivces?
    private var subject: BluetoothSubjects? {
        return btServices?.subject
    }
    
    init(btServices: BtSerivces) {
        self.btServices = btServices
    }
    
    func updateValueForCharacteristic(characteristic: CBCharacteristic) {
        guard let subject = self.subject else { return }
        
        switch characteristic.uuid {
        case Uuid.uniqueName:
            subject.uniqueName.onNext(DeviceName(characteristic: characteristic).name)
        case Uuid.battery:
            subject.battery.onNext(Battery(characteristic: characteristic))
        case Uuid.info:
            subject.deviceInfo.onNext(Version(characteristic))
        default:
            break
        }
    }
}
