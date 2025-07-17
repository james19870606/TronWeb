//
//  ImportAccountFromPrivateKeyViewController.swift
//  TronWebDemo
//
//  Created by Charles on 2024/9/13.
//

import UIKit
import TronWeb3
class ImportAccountFromPrivateKeyViewController: UIViewController {
    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var importAccountFromPrivateKeyBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("import Account From PrivateKey", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(importAccountFromPrivateKeyAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var privateKeyTextView: UITextView = {
        let textView = UITextView()
        textView.text = "3481E79956D4BD95F358AC96D151C976392FC4E3FC132F78A847906DE588C145"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var walletDetailTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "waiting for import Account From PrivateKey"
        return label
    }()

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
        title = "import Account From PrivateKey"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(importAccountFromPrivateKeyBtn,privateKeyTextView, walletDetailTextView, tipLabel)
        importAccountFromPrivateKeyBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        privateKeyTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(100)
            make.height.equalTo(100)
        }
        walletDetailTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(privateKeyTextView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(importAccountFromPrivateKeyBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func importAccountFromPrivateKeyAction() {
        importAccountFromPrivateKeyBtn.isEnabled = false
        tipLabel.text = "importing ..."
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: TRONMainNet) { [weak self] setupResult,error in
                guard let self = self else { return }
                if setupResult {
                    self.importAccountFromPrivateKey()
                }else {
                    print(error)
                }
            }
        } else {
            importAccountFromPrivateKey()
        }
    }

    func importAccountFromPrivateKey() {
        guard let privateKey = privateKeyTextView.text else{return}
        tronWeb.importAccountFromPrivateKey (privateKey: privateKey){ [weak self] state, base58, hex, error in
            guard let self = self else { return }
            self.importAccountFromPrivateKeyBtn.isEnabled = true
            tipLabel.text = "import finished."
            if state {
                let text =
                    "base58: " + base58 + "\n\n" +
                    "hex: " + hex
                walletDetailTextView.text = text
            } else {
                walletDetailTextView.text = error
            }
        }
    }
    

}
