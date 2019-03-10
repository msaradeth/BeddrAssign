

import Foundation
import CoreBluetooth

enum Battery : CustomStringConvertible {

    var description : String {
        switch self {
        case .low:
            return "low battery"
        case .high:
            return "high battery"
        case .unknown:
            return "unknown battery"
        }
    }

    case low
    case high
    case unknown

    init(characteristic: CBCharacteristic) {
 
        precondition(characteristic.uuid == Uuid.battery)
        self = .unknown
        let wordArray = characteristic.value?.withUnsafeBytes {
            [UInt16](UnsafeBufferPointer(start: $0, count: (characteristic.value?.count)!/2))
        }
        if((wordArray?.debugDescription.count)! < 4){
            return
        }
        let pInt = Int(((wordArray?.debugDescription)!).subString(start: 1, end: 3))
        if(pInt! >= 3900){
            self = .high
        }
        else{
            print("[BEDDR][BATTERY]                 BATTERY AS INT" ,pInt!)
            self = .low
        }
    }
}

extension String {
    func subString(start: Int, end: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: end)
        
        let finalString = self.substring(from: startIndex)
        return finalString.substring(to: endIndex)
    }
}
