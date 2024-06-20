//
//  PopViewFeeEstimate.swift
//  TronWebDemo
//
//  Created by Charles on 2024/6/2.
//

import UIKit
let KScreenWidth = UIScreen.main.bounds.size.width

let KScreenHeight = UIScreen.main.bounds.size.height

let KKWindow = UIApplication.shared.windows.first!

typealias TransferConformBlock = ((TransferType) -> Void)

class FeeEstimateView: UIView {
    
    var callback:TransferConformBlock?
    var transferType: TransferType = .trc20

    let contentViewHeight:CGFloat = 260.0
    lazy var contentView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: contentViewHeight))
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
        return view
    }()
    lazy var coverView: UIView = {
        let coverView = UIView.init(frame: UIScreen.main.bounds)
        coverView.backgroundColor = .black
        coverView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss)))
        coverView.alpha = 0.0
        return coverView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "手續費預估中..."
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var resourceConsumedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Resource Consumed "
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    lazy var feeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Fee"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    lazy var cancelBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消交易", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor =  .red
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var nextBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("確認交易", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor =  .red
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame: CGRect,_transferType:TransferType, completion: @escaping TransferConformBlock) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        transferType = _transferType
        callback = completion
        addNotify()
    }
    func addNotify(){
        NotificationCenter.default.addObserver(self, selector: #selector(feeEstimateFinished(_:)), name:Notification.Name(rawValue:"FeeEstimateFinished"), object: nil)
    }
    
    // And transfer trx and trc10, they do not need to cost any energy, it just need some bandwidth
    @objc func feeEstimateFinished(_ notification: Notification){
        self.isUserInteractionEnabled = true
        titleLabel.text = "手續費預估結果"
        guard let dict =  notification.object as? [String:Any]  else { return }
        if transferType == .trc20 {
            if let feeLimit = dict["feeLimit"] as? String,
               let energy_used = dict["energy_used"] as? NSNumber {
                self.resourceConsumedLabel.text = "Resource Consumed  339 Bandwidth" + "         \(String(describing: energy_used)) Energy"
                self.feeLabel.text = "Fee      \(String(describing: feeLimit)) TRX"
            }
        } else {
            if let noteFee = dict["noteFee"] as? Double,let activationFee = dict["activationFee"] as? Double,
               let requiredBandwidth = dict["requiredBandwidth"] as? Double {
                self.resourceConsumedLabel.text = "Resource Consumed  \(Int64(requiredBandwidth)) Bandwidth"
                let totalFee = noteFee + activationFee  + (requiredBandwidth / 1000)
                self.feeLabel.text = "Fee      \(String(describing: totalFee)) TRX"
            }
        }
       
    }
    
    @objc func nextStep(){
        dismiss()
        callback?(transferType)
    }
    
    func setupContentView() {
        let left:CGFloat = 25.0
        let top:CGFloat = 25.0

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(top)
            make.left.equalTo(left)
            make.right.equalTo(-25)

        }
        
        contentView.addSubview(resourceConsumedLabel)
        resourceConsumedLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(left)
        }
        contentView.addSubview(feeLabel)
        
        feeLabel.snp.makeConstraints { make in
            make.top.equalTo(resourceConsumedLabel.snp.bottom).offset(20)
            make.left.equalTo(left)
        }

        contentView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(feeLabel.snp.bottom).offset(20)
            make.left.equalTo(left)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        contentView.addSubview(nextBtn)

        nextBtn.snp.makeConstraints { make in
            make.top.equalTo(feeLabel.snp.bottom).offset(20)
            make.right.equalTo(-25)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

    }
    
    func show(){
        if self.superview == nil {
            KKWindow.addSubview(self)
        }
        self.addSubview(coverView)
        self.addSubview(contentView)
        setupContentView()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.contentView.frame = CGRect(x: 0, y: KScreenHeight - self.contentViewHeight, width: KScreenWidth, height: self.contentViewHeight)
            self.coverView.alpha  = 0.2
        } completion: { _ in
            
        }
    }
    
    @objc func dismiss(){
         UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
             self.contentView.frame = CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: self.contentViewHeight)
             self.coverView.alpha  = 0.0
         } completion: { _ in
             self.removeFromSuperview()
         }
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     deinit {
         print("\(type(of: self)) release")
     }

}
