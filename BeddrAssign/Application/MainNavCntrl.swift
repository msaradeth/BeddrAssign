//
//  MainNavCntrl.swift
//  BeddrAssign
//
//  Created by Mike Saradeth on 3/9/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// MainNavCntrl - Dynamically displays bluetooth status to ViewControllers

class MainNavCntrl: UINavigationController {
    let disposeBag = DisposeBag()
    let subject = BluetoothManager.shared.subject

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.prefersLargeTitles = true
        subject.btStatus.asObservable()
            .subscribe(onNext: { [weak self] (btStatus) in
                self?.displayBtStatusDescription(btStatus: btStatus)
            })
            .disposed(by: disposeBag)
    }
    
    
    // Interate through each ViewControllers and display bluetooth status
    func displayBtStatusDescription(btStatus: BtStatus) {
        for viewController in viewControllers {
            DispatchQueue.main.async {
                viewController.navigationItem.rightBarButtonItem?.title = btStatus.description()
            }
        }
    }
}
