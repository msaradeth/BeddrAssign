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


class MainNavCntrl: UINavigationController {
    let disposeBag = DisposeBag()
    let subject = BluetoothManager.shared.subject

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.prefersLargeTitles = true
        subject.btState.asObservable()
            .subscribe(onNext: { [weak self] (btStatus) in
                self?.displayBtState(btStatus: btStatus)
            })
            .disposed(by: disposeBag)
    }
    
    func displayBtState(btStatus: BtState) {
        for viewController in viewControllers {
            DispatchQueue.main.async {
                viewController.navigationItem.rightBarButtonItem?.title = btStatus.description()
            }
            
        }
    }
}
