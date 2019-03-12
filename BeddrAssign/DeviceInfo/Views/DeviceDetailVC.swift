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
    @IBOutlet weak var deviceInfo: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var slowLabel: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    var viewModel: DetailViewModel!
    
    static func createWith(title: String, viewModel: DetailViewModel) -> DeviceDetailVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "DeviceDetailVC") as! DeviceDetailVC
        vc.title = title
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRx()
    }
    
    func setupRx() {
        guard let subject = viewModel.subject else { return }
        
        subject.uniqueName.asObservable()
            .bind(to: deviceNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.uniqueId.asObservable()
            .bind(to: deviceIdLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.deviceInfo.asObservable()
            .bind(to: deviceInfo.rx.text)
            .disposed(by: disposeBag)

        subject.slowNotifications.asObservable()
            .bind(to: slowLabel.rx.text)
            .disposed(by: disposeBag)
        
        subject.battery.asObservable()
            .bind(to: batteryLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("DeviceDetailVC deinit")
    }
}
