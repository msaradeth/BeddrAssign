//
//  UniqueID.swift
//  Beddr
//
//  Created by Milan Rada on 17.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

struct UniqueID {

    private var characteristic: CBCharacteristic
    private var data: Data
    
    
    
    var id: String {
        var idString: String = ""
        
        for byteIndex in 0...data.count-1 {
            let c = Character(UnicodeScalar(data[byteIndex]))
            idString += String(c)
        }
        return idString
    }
    
    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
        self.data = characteristic.value ?? Data()
    }
}
