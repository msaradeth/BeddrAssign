//
//  BluetoothManager.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//


import Foundation
import CoreBluetooth    //Framework
import RxSwift


class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    
    public var subjectBtState: BehaviorSubject<BtState>!
    public var observable: Observable<BtState> {
        return subjectBtState.asObservable()
    }
    var btStatus: BtState {
        didSet {
            subjectBtState.onNext(btStatus)
        }
    }    
    var currentCommand: NSObject?
    var logArr = [String]()
    
    // MARK: - Properties
    let serviceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    let characteristicUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    var characteristicInstance: CBCharacteristic?
    var peripheralInstance: CBPeripheral?
    
    
    var inBufferByte: Array<UInt8> = [UInt8]()
    var inBufferAscii: String = ""
    
    override init() {
        btStatus = .unknown
        subjectBtState = BehaviorSubject<BtState>(value: btStatus)
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)])
        if let centralManager = centralManager, centralManager.state == .poweredOn {
            btStatus = .poweredOn
        }else {
            btStatus = .poweredOff
        }
    }
    
    
    // MARK: - Bluetooth Helper Functions
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
    
    
    func scanForPeripherals() {
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        
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
    
}


//MARK: - CBCentralManagerDelegate - handles connection
extension BluetoothManager: CBCentralManagerDelegate {
    
    // this method is called based on
    // the device's Bluetooth state; we can ONLY
    // scan for peripherals if Bluetooth is .poweredOn
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            btStatus = .poweredOn
            scanForPeripherals()
        case .poweredOff:
            btStatus = .poweredOff
        default:
            _ = "central.state is default - do nothing at this time."
        }
    }
    
    
    // "Invoked when a connection is successfully created with a peripheral."
    // we can only move forwards when we know the connection
    // to the peripheral succeeded
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        btStatus = .connected
        
        // look for services of interest on peripheral
        peripheralInstance?.discoverServices([serviceUUID])
    }
    
    
    // discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        btStatus = .disconnected
        
        //start scanning
        centralManager?.scanForPeripherals(withServices: [serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        btStatus = .failToConnect
    }
    
    // discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // store a reference to the peripheral in
        // class instance variable
        peripheralInstance = peripheral
        peripheralInstance?.delegate = self
        
        // stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        
        // connect to the discovered peripheral of interest
        centralManager?.connect(peripheralInstance!)
    }
}




//MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == serviceUUID {
                print("Service: \(service)")
                
                // look for characteristics of interest
                // within services of interest
                peripheral.discoverCharacteristics([characteristicUUID], for: service )
            }
        }
    }
    
    
    // confirm we've discovered characteristics
    // of interest within services of interest
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print(characteristic)
            if characteristic.uuid == characteristicUUID {
                characteristicInstance = characteristic
                if isScanning() {
                    stopScan()
                }
                
                // subscribe to regular notifications
                // for characteristic of interest;
                // "When you enable notifications for the
                // characteristic’s value, the peripheral calls
                // ... peripheral(_:didUpdateValueFor:error:)
                //
                // Notify    Mandatory
                //
                peripheral.setNotifyValue(true, for: characteristic)
                
                break
            }
        }
    }
    
    
    // MARK: Handle Bluetooth Reponses
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //convert data to array of [UInt8]
        var bytesData = [UInt8] (repeating: 0, count: characteristic.value!.count)
        (characteristic.value! as NSData).getBytes(&bytesData, length: characteristic.value!.count)
        inBufferByte.append(contentsOf: bytesData)
        
        if let packetDataAscii = String(bytes: bytesData, encoding: String.Encoding.ascii) {
            inBufferAscii.append(packetDataAscii)
        }
    }
}



