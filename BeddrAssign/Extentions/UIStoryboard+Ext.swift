//
//  UIStoryboard+Ext.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    public static func createWith(storyBoard: String, withIdentifier: String) -> UIViewController {
        let vc = UIStoryboard.init(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: withIdentifier)
        let btState = BluetoothManager.shared.btState.description()
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: btState, style: .plain, target: nil, action: nil)
//        vc.navigationItem.rightBarButtonItem?.isEnabled = false
        return vc
    }
}


