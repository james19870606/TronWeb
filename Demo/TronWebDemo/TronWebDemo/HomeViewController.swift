//
//  ViewController.swift
//  TronKit
//
//  Created by Charles on 2022/7/11.
//

import UIKit

class HomeViewController: UIViewController {
    lazy var transferTypes: [TransferType] = TransferType.allCases
    
    lazy var operationTypes: [OperationType] = OperationType.allCases
    
    lazy var chainTypes: [ChainType] = ChainType.allCases
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "首頁"
    }

    func setupContent() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chainType = chainTypes[indexPath.section]
        let operationType = operationTypes[indexPath.row]
        switch operationType {
        case .trxTransfer, .trc20Transfer:
            let transferType = transferTypes[indexPath.row]
            let vc = TransferViewController(chainType, transferType)
            navigationController?.pushViewController(vc, animated: true)
        case .getTRC20TokenBalance,.getTRXBalance:
            let vc = GetBalanceViewController.init(chainType, operationType)
            navigationController?.pushViewController(vc, animated: true)
        case .getAccount:
            print("getAccount")
            let vc = GetAccountViewController.init(chainType, operationType)
            navigationController?.pushViewController(vc, animated: true)
        case .resetTronWebPrivateKey:
            let vc = ResetTronWebPrivateKeyViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        let title = operationTypes[indexPath.row].rawValue
        cell.textLabel?.text = title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chainTypes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = chainTypes[section]
        return title.rawValue
    }
}
