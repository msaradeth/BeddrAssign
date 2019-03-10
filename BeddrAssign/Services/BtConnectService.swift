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

class BtConnectService: BluetoothManager {
    let disposeBag = DisposeBag()

    func requestConnection(peripheral: CBPeripheral, btService: BtSerivces) -> Observable<BtState> {
        return Observable.create({ [unowned self] (observer) -> Disposable in
            btService.connect(peripheral: peripheral)
            btService.subjectBtState.asObservable()
                .skip(1)
                .subscribe(onNext: { (btState) in
                    observer.onNext(btState)
                    observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
}
