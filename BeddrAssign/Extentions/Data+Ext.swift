//
//  Data+Ext.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/10/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation

extension Data {
    func int16(atByte offset: Int) -> Int16 { return subdata(in: offset ..< offset+2).withUnsafeBytes { $0.pointee } }
    func uint32(atByte offset: Int) -> UInt32 { return subdata(in: offset ..< offset+4).withUnsafeBytes { $0.pointee } }
    func float32(atByte offset: Int) -> Float32 { return subdata(in: offset ..< offset+4).withUnsafeBytes { $0.pointee } }
}

