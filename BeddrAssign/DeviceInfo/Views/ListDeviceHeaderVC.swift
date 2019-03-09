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
        vc.navigationItem.title = title
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupRx()
    }
    
    func setupRx() {
        viewModel.itemsSubject.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.shortName
                cell.detailTextLabel?.text = item.fullName
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
        
    deinit {
        print("deinit ListDeviceHeaderVC")
    }
}


extension ListDeviceHeaderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let deviceHeader = viewModel.items[indexPath.row]
        let deviceDetailVC = DeviceDetailVC.createWith(title: deviceHeader.fullName, deviceDetail: deviceHeader.deviceDetail)
        self.navigationController?.pushViewController(deviceDetailVC, animated: true)
        
        //setup to get data from DeviceDetailVC  
        deviceDetailVC.observable
            .subscribe(onNext: { [weak self] (deviceDetail) in
                self?.viewModel.items[indexPath.row].deviceDetail = deviceDetail
            })
            .disposed(by: disposeBag)
    }
}
