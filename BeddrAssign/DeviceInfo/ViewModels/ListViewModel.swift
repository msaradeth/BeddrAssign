//
//  ListViewModel.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import Foundation
import RxSwift

class ListViewModel {
    let disposeBag = DisposeBag()
    var subjectDevice: BehaviorSubject<[DeviceHeader]>
    var items: [DeviceHeader]
    
    init(items: [DeviceHeader], subjectDevice: BehaviorSubject<[DeviceHeader]>) {
        self.items = items
        self.subjectDevice = subjectDevice
    }
}
