//
//  UUID.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/11/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBUUID {
    func toData() -> Data {
        let bytes = [UInt8](self.uuidString.utf8)
        let data = Data(bytes)
        return data
    }
}
