//
//  SignMessageV2ViewController.swift
//  TronWebDemo
//
//  Created by mac on 2025/7/17.
//

import UIKit
import TronWeb3
class SignMessageV2ViewController: UIViewController {

    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var signMessageV2Btn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("SignMessageV2", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(signMessageV2Action), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    lazy var mesessageTextView: UITextView = {
        let textView = UITextView()
        textView.text = "hello world"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var signedTextView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "waiting for import sign Message"
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
        title = "signMessageV2"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(signMessageV2Btn,mesessageTextView, signedTextView, tipLabel)
        signMessageV2Btn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        mesessageTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(100)
            make.height.equalTo(100)
        }
        signedTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(mesessageTextView.snp.bottom).offset(20)
            make.height.equalTo(300)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(signMessageV2Btn.snp.top).offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc func signMessageV2Action() {
        signMessageV2Btn.isEnabled = false
        tipLabel.text = "Signing ..."
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: TRONMainNet) { [weak self] setupResult,error in
                guard let self = self else { return }
                if setupResult {
                    self.signMessageV2()
                }else {
                    print(error)
                }
            }
        } else {
            signMessageV2()
        }
    }

    func signMessageV2() {
        guard let message = mesessageTextView.text else{return}
        let p1 = "57f75d7325d8ba0e6882b4be7afb3bb36"
        let p2 = "b34d184d3c58c28439a9b72cc597d86"
        tronWeb.signMessageV2 (message: message,privateKey: p1 + p2){ [weak self] state, signature, error in
            guard let self = self else { return }
            self.signMessageV2Btn.isEnabled = true
            tipLabel.text = "Signing completed"
            if state {
                signedTextView.text = signature
            } else {
                signedTextView.text = error
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
