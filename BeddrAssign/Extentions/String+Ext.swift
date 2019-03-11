//
//  String+Ext.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/10/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation


extension String {
    func toData() -> Data {
        var byteArr = [UInt8] (self.utf8)
        let data = Data(bytes: &byteArr, count: byteArr.count)
        return data
    }
}



extension String {
    
    // get ASCI array
    
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
    
//    var deviceStatus: ConnectionStatus {
//
//        switch self {
//        case "connected":  return .connected
//        case "disconnected" : return .disconnected
//        default: return .unknown
//        }
//
//    }
    
    var underscoreToCamelCase: String {
        let items = lowercased().components(separatedBy: "_")
        var camelCase = ""
        items.enumerated().forEach {
            camelCase += 0 == $0 ? $1 : $1.capitalized
        }
        return camelCase
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
//    func getAmazonURL() -> URL {
//        let version = Bluetooth.version.value
//        let store = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let path = "\(Account.user!.email)-\(self)-hclog-\(version.fwString ?? "default").dat"
//        print("PATH_", path)
//        return store.appendingPathComponent(path)
//    }
}

