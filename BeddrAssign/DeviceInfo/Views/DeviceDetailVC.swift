//
//  DeviceDetailVC.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import UIKit

class DeviceDetailVC: UIViewController {
    var deviceDetail: DeviceDetail?
    
    static func createWith(title: String, deviceDetail: DeviceDetail?) -> DeviceDetailVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "DeviceDetailVC") as! DeviceDetailVC
        vc.title = title
        vc.deviceDetail = deviceDetail
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
