//
//  ListViewModel.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth

class ListViewModel {
    var subjectDevices: BehaviorSubject<[DeviceHeader]>
    var btServices: BtSerivces?
    var btConnectService: BtConnectService
    
    init(btServices: BtSerivces, btConnectService: BtConnectService) {
        self.btServices = btServices
        self.btConnectService = btConnectService
        self.subjectDevices = btServices.subjectDevices
    }
    
    func connect(peripheral: CBPeripheral?) -> Observable<BtState>? {
        disconnectIfConnected()
        guard let peripheral = peripheral,
            let btServices = self.btServices
            else { return nil }
        return btConnectService.requestConnection(peripheral: peripheral, btService: btServices)
        btServices.connect(peripheral: peripheral)
    }
    
    func disconnectIfConnected() {
        if btServices?.btState == .connected {
            btServices?.disconnect()
        }
    }
}

