//
//  VerifyMessageV2ViewController.swift
//  TronWebDemo
//
//  Created by mac on 2025/7/17.
//

import UIKit
import TronWeb

class VerifyMessageV2ViewController: UIViewController {

    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var verifyMessageV2Btn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("VerifyMessageV2", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(verifyMessageV2Action), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var signatureTextView: UITextView = {
        let textView = UITextView()
        textView.text = "0x67ff16a2816564a239c6f5b8f7239b689b291fc88a48e1e538fc82f0c2f1b7f764ddbf24ac5ff92894309b98a6a6b891bae5a8860195dd22eca1cc136c56e4261c"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var verifyTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "waiting for import Verify Message"
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
        title = "VerifyMessageV2"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(verifyMessageV2Btn,signatureTextView, verifyTextView, tipLabel)
        verifyMessageV2Btn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        signatureTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(100)
            make.height.equalTo(100)
        }
        verifyTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(signatureTextView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(verifyMessageV2Btn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func verifyMessageV2Action() {
        verifyMessageV2Btn.isEnabled = false
        tipLabel.text = "Verifying ..."
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: TRONMainNet) { [weak self] setupResult,error in
                guard let self = self else { return }
                if setupResult {
                    self.verifyMessageV2()
                }else {
                    print(error)
                }
            }
        } else {
            verifyMessageV2()
        }
    }

    func verifyMessageV2() {
        guard let signature = signatureTextView.text else{return}
        tronWeb.verifyMessageV2(message: "hello world", signature: signature) { [weak self] state, base58Address, error in
            guard let self = self else { return }
            self.verifyMessageV2Btn.isEnabled = true
            tipLabel.text = "verifying completed"
            if state {
                verifyTextView.text = base58Address
            } else {
                verifyTextView.text = error
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


}
