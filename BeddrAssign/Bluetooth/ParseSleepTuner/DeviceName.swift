
import Foundation
import CoreBluetooth

struct DeviceName {

    // read
    private var characteristic: CBCharacteristic?
    
    //write
    var data: Data = Data()
    var name: String = ""

    init(name: String) {
        self.name = name
        let nameBytes = name.asciiArray
        for value in nameBytes {
            data.append(UInt8(value))
        }
        data.append(0)
    }
    
    init(characteristic: CBCharacteristic) {
        
        self.characteristic = characteristic
        if let myBytes = characteristic.value {
            for byte in myBytes.map({ UInt8($0) }) {
                if byte != 0 {
                    name.append(String(UnicodeScalar(byte)))
                } else {
                    break
                }
            }
        }
    }
    
}
