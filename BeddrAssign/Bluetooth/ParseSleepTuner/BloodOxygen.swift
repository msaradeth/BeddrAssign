

import Foundation
import CoreBluetooth

enum BloodOxygen :  CustomStringConvertible {


    case unknown
    case sensorSaturated(SlowNotification.Flags)
    case outOfRange(Double)
    case normal(Double)
    
    var description : String {
        switch self {

        case .unknown:
            return "unknown spo2"
        case .sensorSaturated(_):
            return "saturated spo2"
        case .outOfRange(_):
            return "out of range spo2"
        case .normal(_):
            return "normal spo2"
        }
    }
    
    
    var percents_: Double? {
        switch self {
            case .normal(let percents):
                if(percents > 99){
                    return 99
                }
                return percents
            
            default:
                return nil
        }
    }

    init() {
        self = .unknown
    }

    init(_ characteristic: CBCharacteristic) {
        
        precondition(characteristic.uuid == Uuid.slowNotifications)
        
        let notification    = SlowNotification(characteristic)
        let percentage      = Double(notification.bloodOxygen)
        let oximeterFlags   = notification.flags.oximeterFlags
        
        switch true {
            case !oximeterFlags.isEmpty:
                self = .sensorSaturated(oximeterFlags)
        
            case percentage < 70 || percentage > 105:
                self = .outOfRange(percentage)
        
            default:
                self = .normal(percentage)
        }
    }

    
}
