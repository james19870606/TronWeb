//
//  GetChainParametersViewController.swift
//  TronWebDemo
//
//  Created by Charles on 2024/6/1.
//

import UIKit
import TronWeb3

class GetChainParametersViewController: UIViewController {

    var chainType: ChainType = .nile
    var operationType: OperationType = .getChainParameters
    lazy var tronWeb: TronWeb3 = {
        let tronweb = TronWeb3()
        return tronweb
    }()

    lazy var getChainParametersBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("查詢鏈結上參數", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(getChainParametersAction), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var chainParametersInfoTextView: UITextView = {
        let textView = UITextView()
        textView.text = "鏈結上參數資訊…"
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        return textView
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
        title = chainType == .main ? "主網鏈結上參數資訊" : "Nile鏈結上參數資訊"
    }

    func setupContent() {
        view.backgroundColor = .white
        view.addSubviews(getChainParametersBtn, chainParametersInfoTextView)
        getChainParametersBtn.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-100)
            make.height.equalTo(40)
        }
        chainParametersInfoTextView.snp.makeConstraints { make in
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.top.equalTo(100)
            make.bottom.equalTo(getChainParametersBtn.snp.top).offset(-20)
        }
    }

    func getChainParameters() {
        tronWeb.getChainParameters() { [weak self] state, dictArray,error in
            guard let self = self else { return }
            if state {
                if let jsonString = convertDictionaryArrayToString(dictArray){
                    self.chainParametersInfoTextView.text = jsonString
                }
            } else{
                self.chainParametersInfoTextView.text = error
            }
        }
    }

    @objc func getChainParametersAction() {
        if tronWeb.isGenerateTronWebInstanceSuccess != true {
            tronWeb.setup(privateKey: "01", node: chainType == .main ? TRONMainNet : TRONNileNet) { [weak self] setupResult,error in
                guard let self = self else { return }
                if setupResult {
                    self.getChainParameters()
                } else {
                    print(error)
                }
            }
        } else {
            getChainParameters()
        }
    }
}
