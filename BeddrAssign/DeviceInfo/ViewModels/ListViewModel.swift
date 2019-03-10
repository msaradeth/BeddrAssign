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
    let disposeBag = DisposeBag()
    var subjectDevices: BehaviorSubject<[DeviceHeader]>
    var btServices: BtSerivces?
    var btConnectService: BtConnectService
    
    init(btServices: BtSerivces, btConnectService: BtConnectService) {
        self.btServices = btServices
        self.btConnectService = btConnectService
        self.subjectDevices = btServices.subjectDevices
    }
    
    func connect(peripheral: CBPeripheral?, completion: @escaping (BtState) -> Void) {
        disconnectIfConnected()
        guard let peripheral = peripheral, let btServices = self.btServices else {
            completion(.invalidData)
            return
        }
        btConnectService.requestConnection(peripheral: peripheral, btService: btServices)
            .subscribe(onNext: { btState in
                completion(btState)
            })
            .disposed(by: disposeBag)
    }
    
    
    func disconnectIfConnected() {
        if btServices?.btState == .connected {
//            btServices?.disconnect()
        }
    }
}

