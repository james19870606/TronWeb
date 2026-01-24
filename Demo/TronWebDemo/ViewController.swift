//
//  ViewController.swift
//  TronWebDemo
//
//  Created by mac on 2026/1/21.
//

import UIKit
import SnapKit
import TronWeb
class ViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let networkSegment = UISegmentedControl(items: ["Mainnet", "Nile Testnet"])
    
    // List of functionalities data source
    private let sections = [
        ("Wallet Management", [
            "Create Random Wallet",
            "Import Account from Private Key",
            "Import Account from Mnemonic",
            "Switch Wallet (Reset PrivateKey)",
            "Create Multi-Sig Address"
        ]),
        ("Account Query", [
            "Get Account Info (Activation Check)",
            "Get TRX Balance",
            "Get TRC20 Token Balance",
            "Get Account Resources (Energy/Bandwidth)",
            "Get Chain Parameters"
        ]),
        ("Transaction Operations", [
            "TRX Transfer",
            "TRC20 Token Transfer",
            "Multi-Sig TRX Transfer",
            "Multi-Sig TRC20 Transfer",
            "Freeze TRX for Resources (Stake 2.0)",
            "Unfreeze TRX (Stake 2.0)",
            "Delegate Resources"
        ]),
        ("Message Signing & Verification", [
            "Sign Message V2",
            "Verify Message V2"
        ])
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        self.title = "TRON Wallet Demo"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        // Setup Network Switcher in Table Header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        headerView.addSubview(networkSegment)
        networkSegment.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        networkSegment.selectedSegmentIndex = NetworkManager.shared.isMainnet ? 0 : 1
        networkSegment.addTarget(self, action: #selector(handleNetworkChanged), for: .valueChanged)
        tableView.tableHeaderView = headerView
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FunctionCell")
        
        view.addSubview(tableView)
        
        // Use SnapKit for layout
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func handleNetworkChanged() {
       
        NetworkManager.shared.currentNode = networkSegment.selectedSegmentIndex == 0 ? TRONMainNet : TRONNileNet
        print("Network changed to: \(NetworkManager.shared.networkName)")
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FunctionCell", for: indexPath)
        
        let title = sections[indexPath.section].1[indexPath.row]
        
        // Set title
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.font = .systemFont(ofSize: 16)
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFunction = sections[indexPath.section].1[indexPath.row]
        print("User selected function: \(selectedFunction)")
        
        let currentNode = NetworkManager.shared.currentNode
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let vc = CreateRandomWalletViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            let vc = ImportPrivateKeyViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 0 && indexPath.row == 2 {
            let vc = ImportMnemonicViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 0 && indexPath.row == 3 {
            let vc = SwitchWalletViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 0 && indexPath.row == 4 {
            let vc = CreateMultiSigViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let vc = GetAccountInfoViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let vc = GetTRXBalanceViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 2 {
            let vc = GetTRC20BalanceViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 3 {
            let vc = GetAccountResourcesViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 4 {
            let vc = GetChainParametersViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 0 {
            let vc = TRXTransferViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 1 {
            let vc = TRC20TransferViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 2 {
            let vc = MultiSigTRXTransferViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 3 {
            let vc = MultiSigTRC20TransferViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 4 {
            let vc = FreezeBalanceViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 5 {
            let vc = UnfreezeBalanceViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 6 {
            let vc = DelegateResourceViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 3 && indexPath.row == 0 {
            let vc = SignMessageViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 3 && indexPath.row == 1 {
            let vc = VerifyMessageViewController(node: currentNode)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

