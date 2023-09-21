//
//  GetBalanceViewController.swift
//  TronKit
//
//  Created by Charles on 2022/8/29.
//

import Foundation
import SnapKit
import UIKit
import TronWeb
class GetBalanceViewController: UIViewController {
    var chainType: ChainType = .nile
    var operationType: OperationType = .getTRXBalance
    lazy var tronWeb:TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()
    lazy var getBalanceBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("餘額查詢", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(getBalanceAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "等待查詢餘額…"
        return label
    }()
    
    lazy var addressField: UITextField = {
        let addressField = UITextField()
        addressField.borderStyle = .line
        addressField.placeholder = "査詢地址輸入框"
        addressField.text = "TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR"
        return addressField
    }()
    
    lazy var trc20AddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "請輸入trc20合約地址"
        return textField
    }()

    init(_ chainType: ChainType, _ operationType: OperationType) {
        super.init(nibName: nil, bundle: nil)
        self.chainType = chainType
        self.operationType = operationType
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    deinit {
        print("\(type(of: self)) release")
    }
    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = chainType == .main ? "主網獲取餘額" : "Nile測試網獲取餘額"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(getBalanceBtn, addressField, trc20AddressTextField, balanceLabel)
        getBalanceBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        addressField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(40)
        }
        balanceLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(getBalanceBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
        trc20AddressTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(addressField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
       
        trc20AddressTextField.isHidden = operationType == .getTRXBalance
        trc20AddressTextField.text = (chainType == .main) ? Trc20Address.main_trc20.rawValue : Trc20Address.nile_trc20.rawValue
    }
    func getTRXBalance(address: String) {
        tronWeb.getRTXBalance(address: address) { [weak self] state, balance,error in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.chainType == .main ? "主網餘額：" : "Nile測試網餘額： "
                self.balanceLabel.text = title + balance + " TRX"
            } else {
                self.balanceLabel.text = error
            }
        }
    }
    func getTRC20Balance(address: String,trc20Address: String) {
        tronWeb.getTRC20TokenBalance(address: address,
                                     trc20ContractAddress: trc20Address,
                                     decimalPoints: 6.0) { [weak self] state, balance,error in
            guard let self = self else { return }
            self.getBalanceBtn.isEnabled = true
            if state {
                let title = self.chainType == .main ? "主網餘額：" : "Nile測試網餘額： "
                self.balanceLabel.text = title + balance
            } else {
                self.balanceLabel.text = error
            }
        }
    }
    
    @objc func getBalanceAction() {
        getBalanceBtn.isEnabled = false
        balanceLabel.text = "正在查詢餘額…"
        guard let address = addressField.text,let trc20Address = trc20AddressTextField.text else { return }
        
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: chainType == .main ? TRONMainNet : TRONNileNet) { [weak self] setupResult in
                guard let self = self else { return }
                if setupResult {
                    self.operationType == .getTRXBalance ? self.getTRXBalance(address: address) : self.getTRC20Balance(address: address, trc20Address: trc20Address)
                }
            }
        } else {
            operationType == .getTRXBalance ? getTRXBalance(address: address) : getTRC20Balance(address: address, trc20Address: trc20Address)
        }
    }
}
