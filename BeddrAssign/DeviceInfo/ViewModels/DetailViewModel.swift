//
//  DetailViewModel.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation


class DetailViewModel {
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
    
    }
}
