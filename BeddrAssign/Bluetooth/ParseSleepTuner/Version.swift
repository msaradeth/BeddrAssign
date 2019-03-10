//
//  Version.swift
//  Beddr
//
//  Created by Milan Rada on 12.07.17.
//  Copyright © 2017 STRV. All rights reserved.
//

import Foundation
import CoreBluetooth

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}


struct Version {

    var data            : Data

    var majorString     : String!
    var minorString    : String!
    var patchString    : String!
    var fwString        : String!

    init(_ characteristic: CBCharacteristic) {
        precondition(characteristic.uuid == Uuid.info)
        precondition(characteristic.value != nil)
        data = characteristic.value!
        
        let FW      = String(data: data, encoding: String.Encoding.utf8)!
        let indicies = FW.indicesOf(string: ".")
        self.majorString = String(FW[FW.index(FW.startIndex, offsetBy: 0)...FW.index(FW.startIndex, offsetBy: indicies[0]-1)])
        self.minorString = String(FW[FW.index(FW.startIndex, offsetBy: indicies[0]+1)...FW.index(FW.startIndex, offsetBy: indicies[1]-1)])
        self.patchString = String(FW[FW.index(FW.startIndex, offsetBy: indicies[1]+1)...FW.index(FW.startIndex, offsetBy: indicies[2]-1)])
        self.fwString = self.majorString + "." + self.minorString + "." + self.patchString
    }

    init() {
        data = Data()
    }

    /**
    var major: UInt8 {
        return data[0]
        
    }
    var minor: UInt8 { return data[2] }
    var patch: UInt8 { return data[4] }
    var releaseType: Character { return Character(UnicodeScalar(data[3])) }
    var boardVersion: UInt8 { return data[4] }

    var isSupported: Bool { return major == 6 }
    var description: String { return "\(UnicodeScalar(major)).\(UnicodeScalar(minor)).\(UnicodeScalar(patch))"  }
     **/

}
