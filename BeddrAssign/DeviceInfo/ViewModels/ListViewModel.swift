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
    var itemsSubject: BehaviorSubject<[DeviceHeader]>
    var items: [DeviceHeader]
    let disposeBag = DisposeBag()
    
    init(items: [DeviceHeader]) {
        self.items = items
        self.itemsSubject = BehaviorSubject<[DeviceHeader]>(value: items)
    }
}
