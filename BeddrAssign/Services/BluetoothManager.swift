//
//  BluetoothManager.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//


import Foundation
import CoreBluetooth
import RxSwift


class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    // MARK: - Properties
    public var subjectBtState: BehaviorSubject<BtState>
    public var subjectDevices: BehaviorSubject<[DeviceHeader]>
    var btState: BtState {
        didSet {
            subjectBtState.onNext(btState)
        }
    }
    var devices: [DeviceHeader] {
        didSet {
            subjectDevices.onNext(devices)
        }
    }
    var centralManager: CBCentralManager?
    var characteristicInstance: CBCharacteristic?
    var peripheralInstance: CBPeripheral?
    let serviceUUID = Uuid.service

    
    override init() {
        btState = .unknown
        devices = []
        subjectBtState = BehaviorSubject<BtState>(value: btState)
        subjectDevices = BehaviorSubject<[DeviceHeader]>(value: devices)
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)])
        if let centralManager = centralManager, centralManager.state == .poweredOn {
            btState = .poweredOn
            scan()
        }else {
            btState = .poweredOff
        }
    }
}




// MARK: - Bluetooth Service protocol
extension BluetoothManager: BtSerivces {

    
    
    func write(data: Data) {
        guard let peripheralInstance = self.peripheralInstance,
            let characteristicInstance = self.characteristicInstance else {
                return
        }
        
        peripheralInstance.writeValue(data, for: characteristicInstance, type: CBCharacteristicWriteType.withResponse)
        
        //        peripheralInstance?.writeValue(<#T##data: Data##Data#>, for: <#T##CBDescriptor#>)
        //        var bytesData = [UInt8] (cmdInfo.cmd.utf8)
        //        data = Data(bytes: &bytesData, count: bytesData.count)
        
        //        guard let outputStream = self.session?.outputStream else { return }
        //
        //        while outputStream.hasSpaceAvailable && outBuffer.count > 0 {
        //            let bytesWritten = outputStream.write(outBuffer, maxLength: outBuffer.count)
        //            if bytesWritten > 0 {
        //                outBuffer.removeSubrange(..<bytesWritten)  //remove written bytes from buffer
        //            }
        //        }
    }
    
    
    func scan() {
        centralManager?.scanForPeripherals(withServices: [Uuid.service], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
        //        centralManager?.scanForPeripherals(withServices: [serviceUUID])
        
        //        self.blueEar?.didStartConfiguration()
        
        
        //        cbCentralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        //        //        cbCentralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        //
        //        let triggerTime = (Int64(NSEC_PER_SEC) * 9000000)
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
        //            if self.cbCentralManager!.isScanning{
        //                self.cbCentralManager?.stopScan()
        //                //                self.updateViewForStopScanning()
        //            }
        //        })
        
    }
    
    
    public func stopScan() {
        if isScanning() {
            centralManager?.stopScan()
            print("stopScan ...")
        }
    }
    
    public func isScanning() -> Bool {
        return centralManager?.isScanning ?? false
    }
    
    public func connect(peripheral: CBPeripheral?) {
        guard let peripheral = peripheral else {
            btState = .invalidData
            return
        }
        centralManager?.connect(peripheral, options: nil)
    }
    
    
    public func disconnect() {
        guard let peripheral = peripheralInstance else {
            btState = .invalidData
            return
        }
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}




// MARK: - CCBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    // MARK: - CCBCentralManagerDelegate
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        bluetoothState = "centralManagerDidUpdateState"
//        switch (central.state) {
//
//        case .poweredOn:
//            bluetoothEnabled=true
//            startScan()    //scanForPeripherals()
//            break
//        case .poweredOff:
//            bluetoothEnabled=false
//
//        default:
//            break
//        }
//    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
        switch central.state {
        case .poweredOn:
            btState = .poweredOn
            scan()
        case .poweredOff:
            btState = .poweredOff

        default:
            break
        }
    }
    
    
    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        bluetoothState = "didConnect peripheral"
//        bluetoothConnectionStatus = "didConnect"
//        stopScan()
//
//        peripheral.delegate = self
//        peripheral.discoverServices([serviceUUID])
//        self.peripheralInstance = peripheral
//
//        // Post notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didConnectPeripheralNotification), object: nil)
//
//        NSLog("didConnect peripheral: \(String(describing: peripheral.name))")
//
//    }
    
    // "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        btState = .connected
        stopScan()
        
        print("didConnect peripheral:  \(String(describing: peripheral.name))")
        print(peripheral)

        // look for services of interest on peripheral
        peripheralInstance = peripheral
        peripheralInstance?.discoverServices([serviceUUID])
    }
    
    
        //discover what peripheral devices OF INTEREST
        // are available for this app to connect to
//        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//            // store a reference to the peripheral in
//            // class instance variable
//            print("didDiscover peripheral:  \(String(describing: peripheral.name))")
//
//
//            if peripheral.name == "SleepTun" {
//                print(peripheral.name)
//                let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
//                devices.append(deviceHeader)
//                centralManager?.connect(peripheralInstance!)
//    //            peripheralInstance = peripheral
//    //            peripheralInstance?.delegate = self
//    //            centralManager?.stopScan()
//    //            centralManager?.connect(peripheralInstance!)
//            }
//
//            // stop scanning to preserve battery life;
//            // re-scan if disconnected
//
//
//            // connect to the discovered peripheral of interest
//    //        if persistanceDevice?.getUUID() == peripheral.identifier.uuidString && peripheral.state == .disconnected {
//    //            connect(peripheral: peripheral)
//    //        }
//    //        if peripheral.state == .disconnected {
//    //            let pairingDevice = PairingDevice(peripheral: peripheral, rssi: RSSI)
//    //            devices.value.append(pairingDevice)
//    //        }
//
//
//        }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if peripheral.name == "SleepTun" {
            if !devices.contains(where: { $0.peripheral!.identifier == peripheral.identifier}) {
                let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
                print(peripheral.name!, peripheral.identifier.uuidString)
                devices.append(deviceHeader)
            }
            
//            if self.requestConnection == true && btStatus == .disconnected {
////                connect(peripheral: peripheral)
//                centralManager?.connect(peripheral)
//
//                //            if Bikesw.shared.isDisconnected() && peripheralDict.count >= 1 {
//                //                connect(peripheral: peripheral)
//                //            }
//            }
            
            //                if devices.contains(where: { $0.name == peripheral.identifier.uuidString } {
            //                })
            
            
            //                centralManager?.connect(peripheralInstance!)
            //            peripheralInstance = peripheral
            //            peripheralInstance?.delegate = self
            //            centralManager?.stopScan()
            //            centralManager?.connect(peripheralInstance!)
        }
        
        
//        let peripheralConnectable: AnyObject = advertisementData["kCBAdvDataIsConnectable"]! as AnyObject
//
//        if ((self.peripheralInstance == nil || self.peripheralInstance?.state == .disconnected) && (peripheralConnectable as! NSNumber == 1)) {
//            var peripheralName: String = String()
//            if (advertisementData.index(forKey: "kCBAdvDataLocalName") != nil) {
//                peripheralName = advertisementData["kCBAdvDataLocalName"] as! String
//            }
//            if (peripheralName == "" || peripheralName.isEmpty) {
//
//                if (peripheral.name == nil || peripheral.name!.isEmpty) {
//                    peripheralName = "Unknown"
//                } else {
//                    peripheralName = peripheral.name!
//                }
//            }
//
//
//
////            let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
////            devices.append(deviceHeader)
//
//            //            NSLog("Scanning for peripheral: Code:READ,  found: \(peripheralName)")
//            //            peripheralDict.updateValue(PeripheralsStructure(peripheralInstance: peripheral, peripheralRSSI: RSSI, timeStamp: Date()), forKey: peripheralName)
//            //
//            //            NSLog("peripheralName=%@", peripheralName)
////            if (peripheralName.count >= deviceName.count) {
////                let peripheralNamePrefix = String(peripheralName.prefix(deviceName.count))
////                if peripheralNamePrefix == deviceName {
////                    peripheralDict.updateValue(PeripheralsStructure(peripheralInstance: peripheral, peripheralRSSI: RSSI, timeStamp: Date()), forKey: peripheralName)
////                    // Post notification
////                    //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDiscoverPeripheralNotification), object: peripheralDict)
////                }
////            }
////
//
//            ////////////////////////////////
//            //testing
//            //            peripheralDict.updateValue(PeripheralsStructure(peripheralInstance: peripheral, peripheralRSSI: RSSI, timeStamp: Date()), forKey: peripheralName)
//            // Post notification
//            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDiscoverPeripheralNotification), object: peripheralDict)
//            ////////////////////////////////
//
//
//
//            //            NSLog("didDiscover peripheral: \(peripheralName)")
//
//        }
//        if peripheral.name == "SleepTun" {
//            print(peripheral.name)
////            let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
////            devices.append(deviceHeader)
////            centralManager?.connect(peripheralInstance!)
//    //            peripheralInstance = peripheral
//    //            peripheralInstance?.delegate = self
//    //            centralManager?.stopScan()
//    //            centralManager?.connect(peripheralInstance!)
//        }

        // stop scanning to preserve battery life;
        // re-scan if disconnected


        // connect to the discovered peripheral of interest
    //        if persistanceDevice?.getUUID() == peripheral.identifier.uuidString && peripheral.state == .disconnected {
    //            connect(peripheral: peripheral)
    //        }
    //        if peripheral.state == .disconnected {
    //            let pairingDevice = PairingDevice(peripheral: peripheral, rssi: RSSI)
    //            devices.value.append(pairingDevice)
    //        }
        


//        }

        
        
    }
//
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//
//        bluetoothConnectionStatus = "didDisconnectPeripheral"
//        bluetoothState = "didDisconnectPeripheral peripheral"
//        NSLog("didDisconnectPeripheral peripheral: \(String(describing: peripheral.name))")
//        NSLog("error: " + error.debugDescription)
//
//
//        self.peripheralDict.removeAll()
//
//        // Post notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.lostConnectionNotification), object: nil)
//        if Bikesw.shared.btStatus != BtConnectionRequest {
//            //Try to reconnect after disconnect
//            if !Bikesw.shared.isConnected() {
//                //                peripheralInstance = nil
//                startScan()
//            }
//        }
//
//        //Assign BtDisconnected after check if need to scan
//        Bikesw.shared.btStatus = BtDisconnected
//
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        bluetoothState = "didFailToConnect peripheral"
//        bluetoothConnectionStatus = "didFailToConnect"
//
//        Bikesw.shared.btStatus = BtDisconnected
//
//        // Post notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didFailToConnectNotification), object: nil)
//
//        //        alertController = UIAlertController(title: "MLDP Demo", message: "Failed to connect to the peripheral! Check if the peripheral is functioning properly and try to reconnect.", preferredStyle: UIAlertControllerStyle.alert)
//        //        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
//        //        alertController!.addAction(alertAction)
//        //        alertController!.popoverPresentationController?.sourceView = self.view
//        //        alertController!.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 3.0, y: self.view.bounds.size.height / 3.0, width: 1.0, height: 1.0)
//        //        present(alertController!, animated: true, completion: nil)
//    }
//
//    func centralManager(_ central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
//        bluetoothState = "didRetrievePeripherals peripherals"
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        bluetoothState = "didDiscoverServices error"
//
//        if (peripheral.services == nil || peripheral.services!.isEmpty) {
//            //            alertController = UIAlertController(title: "MLDP Demo", message: "Microchip BLE data services not found! Make sure to enter the right custom Service UUID if using custom service. Ensure that the peripheral is configured to enable the custom service.", preferredStyle: UIAlertControllerStyle.alert)
//            //            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
//            //            alertController!.addAction(alertAction)
//            //            alertController!.popoverPresentationController?.sourceView = self.view
//            //            alertController!.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 3.0, y: self.view.bounds.size.height / 3.0, width: 1.0, height: 1.0)
//            //            present(alertController!, animated: true, completion: nil)
//
//            cbCentralManager.cancelPeripheralConnection(peripheral)
//            return
//        }
//
//        for service in peripheral.services! {
//            NSLog("Service discovered: \(service.uuid)")
//            if (service.uuid == serviceUUID) {
//                peripheral.discoverCharacteristics([characteristicUUID], for: service )
//            }
//
//        }
//
//        // Post notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDiscoverServicesNotification), object: nil)
//
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//        var a = RSSI.doubleValue
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        bluetoothState = "didUpdateNotificationStateFor characteristic"
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        bluetoothState = "didDiscoverCharacteristicsFor service"
//
//        if (service.characteristics==nil || service.characteristics!.isEmpty) {
//            //            alertController = UIAlertController(title: "MLDP Demo", message: "Microchip BLE data characteristics not found! Make sure to enter the right custom Characteristics UUIDs if using custom service with characteristics. Ensure that the peripheral is configured to enable the custom service and characteristics.", preferredStyle: UIAlertControllerStyle.alert)
//            //            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
//            //            alertController!.addAction(alertAction)
//            //            alertController!.popoverPresentationController?.sourceView = self.view
//            //            alertController!.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 3.0, y: self.view.bounds.size.height / 3.0, width: 1.0, height: 1.0)
//            //            present(alertController!, animated: true, completion: nil)
//            //
//            cbCentralManager.cancelPeripheralConnection(peripheral)
//            return
//        }
//
//        //        self.peripheralInstance = peripheral
//        for characteristic in service.characteristics! {
//            NSLog("Characteristics discovered: \(characteristic.uuid)")
//            if (service.uuid == serviceUUID) {
//                peripheral.setNotifyValue(true, for: characteristic)
//
//                if (characteristic.uuid == characteristicUUID) {
//                    peripheral.setNotifyValue(true, for: characteristic )
//                    characteristicInstance = characteristic
//
//
//                    NSLog("peripheral.setNotifyValue(true, for: characteristic)")
//                    NSLog("connect Characteristics discovered: \(characteristic.uuid)")
//
//                    let tmpString = String(format:"didDiscoverCharacteristicsFor service: %@", characteristic.uuid)
//                    bluetoothConnectionStatus = tmpString
//
//                    if isScanning() {
//                        stopScan()
//                    }
//                    Bikesw.shared.setActiveDevice(activeDevice: FuelpakBle)
//                    testConnection()
//
//                    break
//                }
//
//            }
//        }
//
//
//
//    }
//
//
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//
//        bluetoothConnectionStatus = "didWriteValueFor characteristic"
//        if Constant.shared.debugOn {
//            NSLog("didWriteValueFor characteristic")
//            NSLog("didWriteValueFor characteristice uuid: \(String(describing: characteristicInstance?.uuid))")
//        }
//
//    }
//
//
//    //
//
//    // MARK: Handle Bluetooth Reponses here
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        bluetoothConnectionStatus = "Got Reponse - didUpdateValueFor characteristic"
//        NSLog("didUpdateValueFor = %@", bluetoothConnectionStatus)
//
//        var bytesData = [UInt8] (repeating: 0, count: characteristic.value!.count)
//        (characteristic.value! as NSData).getBytes(&bytesData, length: characteristic.value!.count)
//
//        self.btDataStreamBytes.append(contentsOf: bytesData)
//
//
//        let packetDataAscii = String(bytes: bytesData, encoding: String.Encoding.ascii)
//
//        self.btDataStreamAscii.append(packetDataAscii!)
//
//        NSLog("btDataStreamAscii:%@", self.btDataStreamAscii)
//
//    }

}

//
////MARK: - CBCentralManagerDelegate - handles connection
//extension BluetoothManager: CBCentralManagerDelegate {
//
//    // this method is called based on
//    // the device's Bluetooth state; we can ONLY
//    // scan for peripherals if Bluetooth is .poweredOn
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//        switch central.state {
//        case .poweredOn:
//            btStatus = .poweredOn
//            scanForPeripherals()
//        case .poweredOff:
//            btStatus = .poweredOff
//            if isScanning() {
////                stopScan()
//            }
//        default:
//            _ = "central.state is default - do nothing at this time."
//        }
//    }
//
//
//    // "Invoked when a connection is successfully created with a peripheral."
//    // we can only move forwards when we know the connection
//    // to the peripheral succeeded
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        btStatus = .connected
//
//        print("didConnect peripheral:  \(String(describing: peripheral.name))")
//        print(peripheral)
//
//        // look for services of interest on peripheral
//        peripheralInstance?.discoverServices([serviceUUID])
//    }
//
//
//    // discover what peripheral devices OF INTEREST
//    // are available for this app to connect to
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        btStatus = .disconnected
//
//        //start scanning
//        centralManager?.scanForPeripherals(withServices: [serviceUUID])
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        btStatus = .failToConnect
//    }
//
//    // discover what peripheral devices OF INTEREST
//    // are available for this app to connect to
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        // store a reference to the peripheral in
//        // class instance variable
//        print("didDiscover peripheral:  \(String(describing: peripheral.name))")
//
//
//        if peripheral.name == "SleepTun" {
//            print(peripheral.name)
//            let deviceHeader = DeviceHeader(shortName: peripheral.name!, peripheral: peripheral)
//            devices.append(deviceHeader)
//            centralManager?.connect(peripheralInstance!)
////            peripheralInstance = peripheral
////            peripheralInstance?.delegate = self
////            centralManager?.stopScan()
////            centralManager?.connect(peripheralInstance!)
//        }
//
//        // stop scanning to preserve battery life;
//        // re-scan if disconnected
//
//
//        // connect to the discovered peripheral of interest
////        if persistanceDevice?.getUUID() == peripheral.identifier.uuidString && peripheral.state == .disconnected {
////            connect(peripheral: peripheral)
////        }
////        if peripheral.state == .disconnected {
////            let pairingDevice = PairingDevice(peripheral: peripheral, rssi: RSSI)
////            devices.value.append(pairingDevice)
////        }
//
//
//    }
//}
//
//
//
//
////MARK: - CBPeripheralDelegate
//extension BluetoothManager: CBPeripheralDelegate {
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("didDiscoverServices error: \(peripheral.services)")
//        for service in peripheral.services! {
//            if service.uuid == serviceUUID {
//                print("Service: \(service)")
//
//                // look for characteristics of interest
//                // within services of interest
//                peripheral.discoverCharacteristics([characteristicUUID], for: service )
//            }
//        }
//    }
//
//
//    // confirm we've discovered characteristics
//    // of interest within services of interest
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        for characteristic in service.characteristics! {
//            print(characteristic)
//            if characteristic.uuid == characteristicUUID {
//                characteristicInstance = characteristic
//                if isScanning() {
//                    stopScan()
//                }
//
//                // subscribe to regular notifications
//                // for characteristic of interest;
//                // "When you enable notifications for the
//                // characteristic’s value, the peripheral calls
//                // ... peripheral(_:didUpdateValueFor:error:)
//                //
//                // Notify    Mandatory
//                //
//                peripheral.setNotifyValue(true, for: characteristic)
//
//                break
//            }
//        }
//    }
//
//
//    // MARK: Handle Bluetooth Reponses
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        //convert data to array of [UInt8]
//        var bytesData = [UInt8] (repeating: 0, count: characteristic.value!.count)
//        (characteristic.value! as NSData).getBytes(&bytesData, length: characteristic.value!.count)
//        inBufferByte.append(contentsOf: bytesData)
//
//        if let packetDataAscii = String(bytes: bytesData, encoding: String.Encoding.ascii) {
//            inBufferAscii.append(packetDataAscii)
//        }
//    }
//}



