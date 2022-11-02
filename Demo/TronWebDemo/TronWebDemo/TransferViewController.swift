//
//  TransferViewController.swift
//  TronKit
//
//  Created by Charles on 2022/8/28.
//

import Foundation
import SnapKit
import UIKit
import SafariServices
import TronWeb
enum ChainType: String, CaseIterable {
    case main
    case nile
}

enum TransferType: String, CaseIterable {
    case trx = "trx_transfer"
    case trc20 = "trc20_transfer"
}

enum OperationType: String, CaseIterable {
    case trxTransfer
    case trc20Transfer
    case getTRC20TokenBalance
    case getTRXBalance
    
    // 用來判斷是否地址是否啟動（上鏈）
    case getAccount
    
    // 多錢包切換需要重新設定TronWebPrivateKey
    case resetTronWebPrivateKey
}

enum Trc20Address: String {
    case main_trc20 = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
    case nile_trc20 = "TXLAQ63Xg1NAzckPwKHvzw7CSEmLMEqcdj"
}

let margin: CGFloat = 20.0

class TransferViewController: UIViewController {
    var chainType: ChainType = .nile
    var transferType: TransferType = .trc20
    lazy var tronWeb:TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()
    lazy var transferBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("轉帳", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(transferAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var privateKeyTextView: UITextView = {
        let textView = UITextView()
        let p1 = "16b59002c68d963359452ad14f"
        let p2 = "79cf58fb49070d7ca2277ebbcbb1de077fe221"
        textView.text = p1 + p2 
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var reviceAddressField: UITextField = {
        let reviceAddressField = UITextField()
        reviceAddressField.borderStyle = .line
        reviceAddressField.placeholder = "收款地址輸入框"
        reviceAddressField.text = "TVpdGyTuzZYXHRAjhhBFabFMU1xFnfmYKj"
        return reviceAddressField
    }()
    
    lazy var trc20AddressTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.placeholder = "請輸入trc20合約地址"
        return textField
    }()
    
    lazy var amountTextField: UITextField = {
        let amountTextField = UITextField()
        amountTextField.borderStyle = .line
        amountTextField.keyboardType = .numberPad
        amountTextField.placeholder = "金額輸入框"
        amountTextField.text = "1"
        return amountTextField
    }()
    
    lazy var remarkTextView: UITextView = {
        let textView = UITextView()
        textView.text = "備註"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var hashLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "交易hash值"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.textColor = .blue
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var detailBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("査詢交易詳情", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(queryAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    init(_ chainType: ChainType, _ transferType: TransferType) {
        super.init(nibName: nil, bundle: nil)
        self.chainType = chainType
        self.transferType = transferType
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    deinit {
        print("\(type(of: self)) release")
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = self.chainType == .main ? "主網轉帳":"Nile測試網轉帳"
    }
    
    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(transferBtn, privateKeyTextView, reviceAddressField, amountTextField, remarkTextView, trc20AddressTextField,hashLabel,detailBtn)
        transferBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        detailBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(transferBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
        hashLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(detailBtn.snp.top).offset(-20)
            make.height.equalTo(60)
        }
        privateKeyTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(80)
        }
        
        reviceAddressField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(privateKeyTextView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(reviceAddressField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        remarkTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(amountTextField.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        trc20AddressTextField.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(remarkTextView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
       
        trc20AddressTextField.isHidden = transferType == .trx
        trc20AddressTextField.text = (chainType == .main) ? Trc20Address.main_trc20.rawValue : Trc20Address.nile_trc20.rawValue
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func trxTransfer() {
        guard let toAddress = reviceAddressField.text,
              let amountText = amountTextField.text,
              let remark = remarkTextView.text else { return }
        tronWeb.trxTransferWithRemark(remark: remark, toAddress: toAddress, amount: amountText) { [weak self] (state, txid) in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            self.hashLabel.text = txid
        }
    }
    
    func trc20Transfer() {
        guard let toAddress = reviceAddressField.text,
              let amountText = amountTextField.text,
              let remark = remarkTextView.text else { return }
        guard let trc20Address = self.trc20AddressTextField.text else { return }
        tronWeb.trc20TokenTransfer(toAddress: toAddress, trc20ContractAddress: trc20Address, amount: amountText, remark: remark, feeLimit: "100000000") { [weak self] (state, txid) in
            guard let self = self else { return }
            print("state = \(state)")
            print("txid = \(txid)")
            self.hashLabel.text = txid
        }
    }
    
    @objc func transferAction() {
        guard let privateKey = privateKeyTextView.text else { return }
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: privateKey, node: chainType == .main ? TRONMainNet : TRONNileNet) { [weak self] setupResult in
                guard let self = self else { return }
                if setupResult {
                    self.transferType == .trx ? self.trxTransfer() : self.trc20Transfer()
                }
            }
        } else {
            transferType == .trx ? trxTransfer() : trc20Transfer()
        }
    }
    
    @objc func queryAction() {
        guard let hash = hashLabel.text,hash.count > 10 else {return}
        var urlString = chainType == .main ?  "https://tronscan.org/#/transaction/" : "https://nile.tronscan.org/#/transaction/"
        urlString += hash
        showSafariVC(for: urlString)
    }
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for index in subviews {
            addSubview(index)
        }
    }
}
