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
        return UIStoryboard.init(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: withIdentifier)
    }
}


