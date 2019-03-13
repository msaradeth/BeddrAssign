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

// ListViewModel - owns Bluetooth Service and Connection Service
// 1.  Request bluetooth connection
// 2.  Disconnect from bluetooth if connnected when in this List Screen

class ListViewModel {
    fileprivate let disposeBag = DisposeBag()
    var subjectDevices: BehaviorSubject<[TunDevice]>
    var btService: BluetoothService?
    var btCharacteristic: BtCharacteristic? {
        return btService?.btCharacteristic
    }
    var btConnectService: BtConnectService
    
    init(btService: BluetoothService, btConnectService: BtConnectService) {
        self.btService = btService
        self.btConnectService = btConnectService
        self.subjectDevices = btService.subject.devices
    }
    
    func connect(peripheral: CBPeripheral?, completion: @escaping (BtStatus) -> Void) {
        disconnectIfConnected()
        guard let peripheral = peripheral, let btService = self.btService else {
            completion(.invalidData)
            return
        }
        
        // Request connection and emit result to subscriber
        btConnectService.requestConnection(peripheral: peripheral, btService: btService)
            .subscribe(onNext: { btStatus in
                completion(btStatus)
            })
            .disposed(by: disposeBag)
    }
    
    
    func disconnectIfConnected() {
        if btService?.btStatus == .connected {
            btService?.disconnect()
        }
    }
}

