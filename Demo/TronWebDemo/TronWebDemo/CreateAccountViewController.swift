//
//  CreateAccountViewController.swift
//  TronWebDemo
//
//  Created by Charles on 2023/9/21.
//

import TronWeb
import UIKit
class CreateAccountViewController: UIViewController {
    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var createAccountBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("createAccount", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(createAccountAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
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
        label.text = "wait for create Account"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }

    func setupView() {
        setupNav()
        setupContent()
    }

    func setupNav() {
        title = "create Account"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(createAccountBtn, walletDetailTextView, tipLabel)
        createAccountBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        walletDetailTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(createAccountBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func createAccountAction() {
        createAccountBtn.isEnabled = false
        tipLabel.text = "creating ..."
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: TRONMainNet) { [weak self] setupResult in
                guard let self = self else { return }
                if setupResult {
                    self.createAccount()
                }
            }
        } else {
            createAccount()
        }
    }

    func createAccount() {
        tronWeb.createAccount { [weak self] state, base58Address, hexAddress, privateKey, publicKey, error in
            guard let self = self else { return }
            self.createAccountBtn.isEnabled = true
            tipLabel.text = "create finished."
            if state {
                let text =
                    "base58Address: " + base58Address + "\n\n" +
                    "hexAddress: " + hexAddress + "\n\n" +
                    "privateKey: " + privateKey + "\n\n" +
                    "publicKey: " + publicKey
                walletDetailTextView.text = text
            } else {
                walletDetailTextView.text = error
            }
        }
    }
}
