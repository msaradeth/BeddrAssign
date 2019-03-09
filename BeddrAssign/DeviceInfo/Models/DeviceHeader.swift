//
//  DeviceHeader.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation

struct DeviceHeader {
    var shortName:String
    var fullName: String
    var deviceDetail: DeviceDetail?
    
    init(shortName: String, fullName: String, deviceDetail: DeviceDetail? = nil) {
        self.shortName = shortName
        self.fullName = fullName
        self.deviceDetail = deviceDetail
    }
}
