//
//  ConnectService.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth


// A service to connect to bluetooth
// Emits bluetooth status to subscribers
class BtConnectService: BluetoothManager {
    let disposeBag = DisposeBag()

    func requestConnection(peripheral: CBPeripheral, btService: BluetoothService) -> Observable<BtStatus> {
        return Observable.create({ [unowned self] (observer) -> Disposable in
            btService.connect(peripheral: peripheral)
            btService.subject.btStatus.asObservable()
                .skip(1)
                .delay(0.5, scheduler: MainScheduler.instance)    //Add delay 0.5 of a second to get characteristics
                .subscribe(onNext: { (btStatus) in
                    observer.onNext(btStatus)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
}
