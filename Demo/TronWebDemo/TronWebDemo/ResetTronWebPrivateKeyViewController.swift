//
//  ResetTronWebPrivateKeyViewController.swift
//  TronKit
//
//  Created by Charles on 2022/8/30.
//

import Foundation
import UIKit
import TronWeb3
class ResetTronWebPrivateKeyViewController: UIViewController {
    lazy var tronWeb:TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()
    lazy var resetTronWebPKBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("重新設定privateKey", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(resetTronWebPKAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var privateKeyTextView: UITextView = {
        let textView = UITextView()
        textView.text = "48bc5cf8d36b8747f109a975ddf46dc4642cc286889b3969f500feb9e41d3c4b"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
    
    lazy var descTextView: UITextView = {
        let textView = UITextView()
        textView.text = "同一個App下有多個波場錢包，在進行錢包切換的時候，會使用到. \n當然也可以重新調用TronWeb.setup（）方法重新創建TronWeb實例，只是效率沒有重置私密金鑰那麼高"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
    }()
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
        setupTronweb()
    }
    
    func setupTronweb(){
        guard let privateKey = privateKeyTextView.text else { return }
        tronWeb.setup(privateKey: privateKey) {  setupResult,error in
            if setupResult {

            } else {
                print(error)
            }
        }

    }

    func setupNav() {
        title = "設定privateKey"
    }

    func setupContent() {
        view.backgroundColor = .white
        
        view.addSubviews(resetTronWebPKBtn, privateKeyTextView, descTextView)
        resetTronWebPKBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        privateKeyTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(150)
            make.height.equalTo(80)
        }
        descTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(privateKeyTextView.snp.bottom).offset(20)
            make.height.equalTo(188)
        }
    }
    
    @objc func resetTronWebPKAction() {
        guard let privateKey = privateKeyTextView.text else { return }
        tronWeb.tronWebResetPrivateKey(privateKey: privateKey){ result in
            if result {
              print("重置成功")
            } else {
                print("重置失敗")
            }
        }
    }
}
