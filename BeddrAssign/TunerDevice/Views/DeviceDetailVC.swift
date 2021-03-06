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

// DeviceDetailVC:  Ownes DetailViewModel which should have everything it needs
// Display detail information for selected device
// Allows user to toggle notifications for Battery and SlowNotifications
// Read data from UniqueID and Info characteristics

class DeviceDetailVC: UIViewController {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var deviceInfo: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var slowLabel: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    var viewModel: DetailViewModel!
    
    // Inject need objects used by this view controller
    static func createWith(title: String, viewModel: DetailViewModel) -> DeviceDetailVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "DeviceDetailVC") as! DeviceDetailVC
        vc.title = title
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind data to views
        setupRx()
        
        //Read Device Values
        viewModel.readDeviceValues()
    }
    
    
    // Bind data to views
    func setupRx() {
        guard let subject = viewModel.subject else { return }
        
        subject.uniqueName.asObservable()
            .bind(to: deviceNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.uniqueId.asObservable()
            .bind(to: deviceIdLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.tunDevice.asObservable()
            .bind(to: deviceInfo.rx.text)
            .disposed(by: disposeBag)

        subject.slowNotifications.asObservable()
            .bind(to: slowLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.battery.asObservable()
            .bind(to: batteryLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // Toggles notifications
    @IBAction func toggleSlowNotification(_ sender: Any) {
        viewModel.toggleNotification(characteristic: viewModel.btCharacteristic?.slowNotifications)
    }
    @IBAction func toggleBatteryNotification(_ sender: Any) {
        viewModel.toggleNotification(characteristic: viewModel.btCharacteristic?.battery)
    }
        
    deinit {
        print("DeviceDetailVC deinit")
    }
}
