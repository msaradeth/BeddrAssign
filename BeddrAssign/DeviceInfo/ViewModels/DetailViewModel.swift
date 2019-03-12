//
//  DetailViewModel.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift


class DetailViewModel {
    let bag = DisposeBag()
    var btService: BluetoothService?
    var subject: BluetoothSubject? {
        return btService?.subject
    }
    var commands: [SendCommand]
    
    init(btService: BluetoothService?) {
        self.btService = btService

        commands = []
    }
    
    func sendCommands() {
        guard commands.count > 0 else { return }
        
        let command = commands.removeFirst()
        command.subject.asObservable()
            .subscribe(onNext: { (cmdStatus) in
                print(cmdStatus)
            }, onError: { (error) in
                print("onError:  \(error)")
                self.sendCommands()
            }, onCompleted: {
                print("completed")
                self.sendCommands()
            })
            .disposed(by: bag)
        
        btService?.write(sendCommand: command)
    }
    
    func prepCommands() {
        let deviceNameCmd = SendCommand(data: Uuid.uniqueName.toData(), characteristic: btService?.btCharacteristic.deviceInfo)
        let deviceIdCmd = SendCommand(data: Uuid.uniqueId.toData(), characteristic: btService?.btCharacteristic.deviceInfo)
        let infoCmd = SendCommand(data: Uuid.info.toData(), characteristic: btService?.btCharacteristic.deviceInfo)
        commands = [deviceNameCmd, deviceIdCmd, infoCmd]
    }
    
    
    deinit {
        print("DetailViewModel deinit")
    }
}
