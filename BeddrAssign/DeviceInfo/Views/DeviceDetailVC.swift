//
//  DeviceDetailVC.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class DeviceDetailVC: UIViewController {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var deviceStatus: UILabel!
    @IBOutlet weak var deviceInfo: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var btService: BtSerivces?
    var subject: BluetoothSubjects? {
        return btService?.subject
    }
    
    static func createWith(title: String, btService: BtSerivces?) -> DeviceDetailVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "DeviceDetailVC") as! DeviceDetailVC
        vc.title = title
        vc.btService = btService
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setupRx() {
        guard let subject = self.subject else { return }
        
        subject.uniqueName.asObservable()
            .bind(to: deviceNameLabel.rx.text)
            .disposed(by: disposeBag)
        
//        subject.deviceInfo.asObservable()
//            .bind(to: deviceNameLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        subject.uniqueName.asObservable()
//            .bind(to: deviceNameLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        subject.uniqueName.asObservable()
//            .bind(to: deviceNameLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        subject.uniqueName.asObservable()
//            .bind(to: deviceNameLabel.rx.text)
//            .disposed(by: disposeBag)
        
        subject.battery.asObservable()
            .bind(to: batteryLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
}
