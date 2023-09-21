//
//  CreateRandomViewController.swift
//  TronWebDemo
//
//  Created by Charles on 2023/9/21.
//

import TronWeb
import UIKit

class CreateRandomViewController: UIViewController {
    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var createRandomBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("createRandom", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(createRandomAction), for: .touchUpInside)
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
        label.text = "wait for create Random"
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
        title = "create Random"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(createRandomBtn, walletDetailTextView, tipLabel)
        createRandomBtn.snp.makeConstraints { make in
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
            make.bottom.equalTo(createRandomBtn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func createRandomAction() {
        createRandomBtn.isEnabled = false
        tipLabel.text = "creating ..."
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: TRONMainNet) { [weak self] setupResult in
                guard let self = self else { return }
                if setupResult {
                    self.createRandom()
                }
            }
        } else {
            createRandom()
        }
    }

    func createRandom() {
        tronWeb.createRandom { [weak self] state, address, privateKey, publicKey, mnemonic, error in
            guard let self = self else { return }
            self.createRandomBtn.isEnabled = true
            tipLabel.text = "create finished."
            if state {
                let text =
                    "address: " + address + "\n\n" +
                    "mnemonic: " + mnemonic + "\n\n" +
                    "privateKey: " + privateKey + "\n\n" +
                    "publicKey: " + publicKey
                walletDetailTextView.text = text
            } else {
                walletDetailTextView.text = error
            }
        }
    }
}
