//
//  DeviceDetailVC.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import UIKit
import RxSwift

class DeviceDetailVC: UIViewController {
    private var subjectDeviceDetail: PublishSubject<DeviceDetail?>!
    var observable: Observable<DeviceDetail?> {
        return subjectDeviceDetail.asObservable()
    }
    var deviceDetail: DeviceDetail?
    
    static func createWith(title: String, deviceDetail: DeviceDetail?) -> DeviceDetailVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "DeviceDetailVC") as! DeviceDetailVC
        vc.title = title
        vc.deviceDetail = deviceDetail
        vc.subjectDeviceDetail = PublishSubject<DeviceDetail?>()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        subjectDeviceDetail.onNext(deviceDetail)
        subjectDeviceDetail.onCompleted()
    }
    
    deinit {
        print("deinit DeviceDetailVC")
    }
}
