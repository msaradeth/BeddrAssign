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


// ListDeviceVC:  Ownes ListViewModel which should have everything it needs
// Dynamically displays list of devices dicovered
// Allows user to select an item
// Request connection and if successful, go to detail screen

class ListDeviceVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate let disposeBag = DisposeBag()
    var viewModel: ListViewModel!
    
    // Inject needed objects to ListViewVC
    static func createWith(title: String, viewModel: ListViewModel) -> ListDeviceVC {
        let vc = UIStoryboard.createWith(storyBoard: "BeddrDevices", withIdentifier: "ListDeviceHeaderVC") as! ListDeviceVC
        vc.viewModel = viewModel
        DispatchQueue.main.async {
            vc.navigationItem.title = title
        }
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind data to views
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.disconnectIfConnected()
    }
    
    
    func setupRx() {
        // Display items to list
        viewModel.subjectDevices.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, item, cell) in
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.uuidString
            }
            .disposed(by: disposeBag)
        
        // Handle item selection
        tableView.rx
            .modelSelected(DeviceInfo.self)
            .subscribe(onNext: { [weak self] deviceInfo in
                guard let this = self else { return }
                let indexPath = this.tableView.indexPathForSelectedRow
                this.tableView.deselectRow(at: indexPath!, animated: true)
                
                //Request bluetooth connection, if successful, go to detail screen after connected
                this.viewModel.connect(peripheral: deviceInfo.peripheral, completion: { (btStatus) in
                    if btStatus == .connected {
                        //Injected objects needed for detail screen
                        let detailViewModel = DetailViewModel(btService: this.viewModel.btService, deviceInfo: deviceInfo)
                        let deviceDetailVC = DeviceDetailVC.createWith(title: "Device Detail", viewModel: detailViewModel)
                        this.navigationController?.pushViewController(deviceDetailVC, animated: true)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    
}



