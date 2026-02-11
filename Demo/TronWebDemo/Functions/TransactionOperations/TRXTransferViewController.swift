import UIKit
import SnapKit
import SafariServices

class TRXTransferViewController: UIViewController {

    // MARK: - Properties
    private let tronWeb = TronWeb()
    private let selectedNode: String
    private var lastTxid: String?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let fromAddressLabel = UILabel()
    private let fromAddressTextField = UITextField()
    
    private let toAddressLabel = UILabel()
    private let toAddressTextField = UITextField()
    
    private let amountLabel = UILabel()
    private let amountTextField = UITextField()
    
    private let remarkLabel = UILabel()
    private let remarkTextField = UITextField()
    
    private let privateKeyLabel = UILabel()
    private let privateKeyTextField = UITextField()
    
    private let estimateButton = UIButton(type: .system)
    private let transferButton = UIButton(type: .system)
    private let resultTextView = UITextView()
    private let viewOnExplorerButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)

    // MARK: - Init
    init(node: String) {
        self.selectedNode = node
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "TRX Transfer"
        setupUI()
        updateNetworkStatus()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Network Status
        networkStatusLabel.textAlignment = .center
        networkStatusLabel.font = .systemFont(ofSize: 14, weight: .bold)
        networkStatusLabel.layer.cornerRadius = 4
        networkStatusLabel.layer.masksToBounds = true
        contentView.addSubview(networkStatusLabel)
        networkStatusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        // From Address
        fromAddressLabel.text = "From Address (for Estimation):"
        contentView.addSubview(fromAddressLabel)
        fromAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        fromAddressTextField.placeholder = "T... (Used for fee estimation)"
        fromAddressTextField.borderStyle = .roundedRect
        fromAddressTextField.autocapitalizationType = .none
        fromAddressTextField.autocorrectionType = .no
        contentView.addSubview(fromAddressTextField)
        fromAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(fromAddressLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // To Address
        toAddressLabel.text = "To Address:"
        contentView.addSubview(toAddressLabel)
        toAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(fromAddressTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        toAddressTextField.placeholder = "T..."
        toAddressTextField.borderStyle = .roundedRect
        toAddressTextField.autocapitalizationType = .none
        toAddressTextField.autocorrectionType = .no
        contentView.addSubview(toAddressTextField)
        toAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(toAddressLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Amount
        amountLabel.text = "Amount (TRX):"
        contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(toAddressTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        amountTextField.placeholder = "0.0"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        contentView.addSubview(amountTextField)
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Remark (Memo)
        remarkLabel.text = "Remark (Memo - Optional):"
        contentView.addSubview(remarkLabel)
        remarkLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        remarkTextField.placeholder = "Enter transaction memo"
        remarkTextField.borderStyle = .roundedRect
        contentView.addSubview(remarkTextField)
        remarkTextField.snp.makeConstraints { make in
            make.top.equalTo(remarkLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Private Key
        privateKeyLabel.text = "Sender Private Key (Hex):"
        contentView.addSubview(privateKeyLabel)
        privateKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(remarkTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        privateKeyTextField.placeholder = "64-digit hex"
        privateKeyTextField.borderStyle = .roundedRect
        privateKeyTextField.isSecureTextEntry = true
        privateKeyTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        privateKeyTextField.autocapitalizationType = .none
        privateKeyTextField.autocorrectionType = .no
        contentView.addSubview(privateKeyTextField)
        privateKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(privateKeyLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Estimate Button
        estimateButton.setTitle("Estimate Fee", for: .normal)
        estimateButton.backgroundColor = .systemGray5
        estimateButton.setTitleColor(.systemBlue, for: .normal)
        estimateButton.layer.cornerRadius = 8
        estimateButton.addTarget(self, action: #selector(handleEstimate), for: .touchUpInside)
        contentView.addSubview(estimateButton)
        estimateButton.snp.makeConstraints { make in
            make.top.equalTo(privateKeyTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.height.equalTo(50)
        }
        
        // Transfer Button
        transferButton.setTitle("Send TRX", for: .normal)
        transferButton.backgroundColor = .systemBlue
        transferButton.setTitleColor(.white, for: .normal)
        transferButton.layer.cornerRadius = 8
        transferButton.addTarget(self, action: #selector(handleTransfer), for: .touchUpInside)
        contentView.addSubview(transferButton)
        transferButton.snp.makeConstraints { make in
            make.top.equalTo(privateKeyTextField.snp.bottom).offset(30)
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        // Result
        resultTextView.isEditable = false
        resultTextView.layer.borderColor = UIColor.systemGray4.cgColor
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.cornerRadius = 8
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        contentView.addSubview(resultTextView)
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(transferButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        // Use StackView to manage bottom buttons
        let buttonStackView = UIStackView(arrangedSubviews: [viewOnExplorerButton, copyButton])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fill
        
        contentView.addSubview(buttonStackView)
        
        viewOnExplorerButton.setTitle("View on TronScan", for: .normal)
        viewOnExplorerButton.backgroundColor = .systemGreen
        viewOnExplorerButton.setTitleColor(.white, for: .normal)
        viewOnExplorerButton.layer.cornerRadius = 8
        viewOnExplorerButton.isHidden = true // Hidden by default
        viewOnExplorerButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        viewOnExplorerButton.addTarget(self, action: #selector(handleViewOnExplorer), for: .touchUpInside)
        
        copyButton.setTitle("Copy JSON Result", for: .normal)
        copyButton.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(resultTextView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func updateNetworkStatus() {
        if selectedNode == TRONMainNet {
            networkStatusLabel.text = "NETWORK: MAINNET"
            networkStatusLabel.textColor = .white
            networkStatusLabel.backgroundColor = .systemGreen
        } else {
            networkStatusLabel.text = "NETWORK: NILE TESTNET"
            networkStatusLabel.textColor = .black
            networkStatusLabel.backgroundColor = .systemPink
        }
    }

    @objc private func handleEstimate() {
        let fromAddress = fromAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let toAddress = toAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let remark = remarkTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard let amount = Double(amountStr), amount >= 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        if fromAddress.isEmpty || toAddress.isEmpty {
            showAlert(message: "Please enter both sender and destination addresses to estimate fee")
            return
        }
        
        Task {
            estimateButton.isEnabled = false
            resultTextView.text = "Initializing TronWeb for estimation..."
            
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                do {
                    try await tronWeb.setupAsync(privateKey: "01", node: selectedNode)
                    await executeEstimate(fromAddress: fromAddress, toAddress: toAddress, amount: amount, remark: remark)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.estimateButton.isEnabled = true
                }
            } else {
                await executeEstimate(fromAddress: fromAddress, toAddress: toAddress, amount: amount, remark: remark)
            }
        }
    }
    
    private func executeEstimate(fromAddress: String, toAddress: String, amount: Double, remark: String) async {
        let response = await self.tronWeb.estimateTrxFeeAsync(toAddress: toAddress, amount: amount, fromAddress: fromAddress, remark: remark)
        self.estimateButton.isEnabled = true
        
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.resultTextView.text = jsonString
            } else {
                self.resultTextView.text = "\(response)"
            }
        } else {
            self.resultTextView.text = "Failed to receive fee estimation from TronWeb"
        }
    }
    
    @objc private func handleTransfer() {
        let toAddress = toAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let privateKey = privateKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let remark = remarkTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard let amount = Double(amountStr), amount > 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        if toAddress.isEmpty || privateKey.isEmpty {
            showAlert(message: "Please enter both destination address and private key")
            return
        }
        
        Task {
            transferButton.isEnabled = false
            viewOnExplorerButton.isHidden = true
            lastTxid = nil
            resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
            
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                do {
                    try await tronWeb.setupAsync(privateKey: privateKey, node: selectedNode)
                    await executeTransfer(toAddress: toAddress, amount: amount, privateKey: privateKey, remark: remark)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.transferButton.isEnabled = true
                }
            } else {
                await executeTransfer(toAddress: toAddress, amount: amount, privateKey: privateKey, remark: remark)
            }
        }
    }
    
    private func executeTransfer(toAddress: String, amount: Double, privateKey: String, remark: String) async {
        transferButton.isEnabled = false
        resultTextView.text = "Broadcasting transaction..."
        
        let response = await tronWeb.trxTransferAsync(toAddress: toAddress, amount: amount, privateKey: privateKey, remark: remark)
        self.transferButton.isEnabled = true
        
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.resultTextView.text = jsonString
            } else {
                self.resultTextView.text = "\(response)"
            }
            
            // Extract txid
            var capturedTxid: String?
            if let resultDict = response["result"] as? [String: Any],
               let txid = resultDict["txid"] as? String {
                capturedTxid = txid
            } else if let txid = response["txid"] as? String {
                capturedTxid = txid
            } 
            
            if let txid = capturedTxid {
                self.lastTxid = txid
                self.viewOnExplorerButton.isHidden = false
            }
        } else {
            self.resultTextView.text = "Failed to receive response from TronWeb"
        }
    }
    
    @objc private func handleViewOnExplorer() {
        guard let txid = lastTxid else { return }
        let baseUrl = selectedNode == TRONMainNet ? "https://tronscan.org" : "https://nile.tronscan.org"
        let urlString = "\(baseUrl)/#/transaction/\(txid)"
        
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleCopy() {
        guard let text = resultTextView.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        let alert = UIAlertController(title: "Success", message: "Result copied to clipboard", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
