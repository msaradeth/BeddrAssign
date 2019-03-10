//
//  ListVC.swift
//  Assignment
//
//  Created by Mike Saradeth on 3/8/19.
//  Copyright © 2019 Mike Saradeth. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListDeviceHeaderVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    var viewModel: ListViewModel!
    
    static func createWith(title: String, viewModel: ListViewModel) -> ListDeviceHeaderVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "ListDeviceHeaderVC") as! ListDeviceHeaderVC
        vc.viewModel = viewModel
        DispatchQueue.main.async {
            vc.navigationItem.title = title
        }
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.disconnectIfConnected()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    func setupRx() {
        viewModel.subjectDevices.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.uuidString
                cell.detailTextLabel?.text = item.shortName
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(DeviceHeader.self)
            .subscribe(onNext: { [weak self] deviceHeader in
                guard let this = self else { return }
                let indexPath = this.tableView.indexPathForSelectedRow
                this.tableView.deselectRow(at: indexPath!, animated: true)
                this.viewModel.connect(peripheral: deviceHeader.peripheral)?
                    .subscribe(onNext: { btState in
                        if btState == .connected {
                            let deviceDetailVC = DeviceDetailVC.createWith(title: "Device Detail", deviceDetail: deviceHeader.deviceDetail)
                            this.navigationController?.pushViewController(deviceDetailVC, animated: true)
                        }
                    })
                    .disposed(by: this.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
}



