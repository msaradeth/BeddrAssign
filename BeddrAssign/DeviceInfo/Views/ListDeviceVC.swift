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

class ListDeviceVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: ListViewModel!
    
    static func createWith(title: String, viewModel: ListViewModel) -> ListDeviceVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "ListDeviceHeaderVC") as! ListDeviceVC
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
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.uuidString
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(DeviceInfo.self)
            .subscribe(onNext: { [weak self] deviceInfo in
                guard let this = self else { return }
                let indexPath = this.tableView.indexPathForSelectedRow
                this.tableView.deselectRow(at: indexPath!, animated: true)
                this.viewModel.connect(peripheral: deviceInfo.peripheral, completion: { (btStatus) in
                    if btStatus == .connected {
                        let detailViewModel = DetailViewModel(btService: this.viewModel.btService, deviceInfo: deviceInfo)
                        let deviceDetailVC = DeviceDetailVC.createWith(title: "Device Detail", viewModel: detailViewModel)
                        this.navigationController?.pushViewController(deviceDetailVC, animated: true)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    
}



