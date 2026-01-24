import UIKit
import SnapKit
import SafariServices

class MultiSigTRC20TransferViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String
    private var lastTxid: String?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let contractAddressLabel = UILabel()
    private let contractAddressTextField = UITextField()
    
    private let fromAddressLabel = UILabel()
    private let fromAddressTextField = UITextField()
    
    private let toAddressLabel = UILabel()
    private let toAddressTextField = UITextField()
    
    private let amountLabel = UILabel()
    private let amountTextField = UITextField()
    
    private let privateKeysLabel = UILabel()
    private let privateKeysTextView = UITextView()
    private let privateKeysHintLabel = UILabel()
    
    private let permissionIdLabel = UILabel()
    private let permissionIdTextField = UITextField()
    
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
        self.title = "Multi-Sig TRC20 Transfer"
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
        
        // Contract Address
        contractAddressLabel.text = "TRC20 Contract Address (e.g. USDT):"
        contentView.addSubview(contractAddressLabel)
        contractAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        contractAddressTextField.placeholder = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
        contractAddressTextField.text = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
        contractAddressTextField.borderStyle = .roundedRect
        contractAddressTextField.autocapitalizationType = .none
        contractAddressTextField.autocorrectionType = .no
        contentView.addSubview(contractAddressTextField)
        contractAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(contractAddressLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // From Address
        fromAddressLabel.text = "Multi-Sig Account Address (From):"
        contentView.addSubview(fromAddressLabel)
        fromAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(contractAddressTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        fromAddressTextField.placeholder = "T..."
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
        toAddressLabel.text = "Recipient Address (To):"
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
        amountLabel.text = "Amount (Tokens):"
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
        
        // Private Keys
        privateKeysLabel.text = "Signer Private Keys (One per line):"
        contentView.addSubview(privateKeysLabel)
        privateKeysLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        privateKeysTextView.layer.borderColor = UIColor.systemGray4.cgColor
        privateKeysTextView.layer.borderWidth = 1
        privateKeysTextView.layer.cornerRadius = 8
        privateKeysTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        privateKeysTextView.autocapitalizationType = .none
        privateKeysTextView.autocorrectionType = .no
        contentView.addSubview(privateKeysTextView)
        privateKeysTextView.snp.makeConstraints { make in
            make.top.equalTo(privateKeysLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        privateKeysHintLabel.text = "Keys must meet the multi-sig threshold"
        privateKeysHintLabel.font = .systemFont(ofSize: 12)
        privateKeysHintLabel.textColor = .systemGray
        contentView.addSubview(privateKeysHintLabel)
        privateKeysHintLabel.snp.makeConstraints { make in
            make.top.equalTo(privateKeysTextView.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
        }
        
        // Permission ID
        permissionIdLabel.text = "Permission ID (Active=2):"
        contentView.addSubview(permissionIdLabel)
        permissionIdLabel.snp.makeConstraints { make in
            make.top.equalTo(privateKeysHintLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        permissionIdTextField.text = "2"
        permissionIdTextField.borderStyle = .roundedRect
        permissionIdTextField.keyboardType = .numberPad
        contentView.addSubview(permissionIdTextField)
        permissionIdTextField.snp.makeConstraints { make in
            make.top.equalTo(permissionIdLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
        // Buttons
        estimateButton.setTitle("Estimate Fee", for: .normal)
        estimateButton.backgroundColor = .systemGray5
        estimateButton.setTitleColor(.systemBlue, for: .normal)
        estimateButton.layer.cornerRadius = 8
        estimateButton.addTarget(self, action: #selector(handleEstimate), for: .touchUpInside)
        contentView.addSubview(estimateButton)
        estimateButton.snp.makeConstraints { make in
            make.top.equalTo(permissionIdTextField.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.height.equalTo(50)
        }
        
        transferButton.setTitle("Send Multi-Sig TRC20", for: .normal)
        transferButton.backgroundColor = .systemBlue
        transferButton.setTitleColor(.white, for: .normal)
        transferButton.layer.cornerRadius = 8
        transferButton.addTarget(self, action: #selector(handleTransfer), for: .touchUpInside)
        contentView.addSubview(transferButton)
        transferButton.snp.makeConstraints { make in
            make.top.equalTo(permissionIdTextField.snp.bottom).offset(30)
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

    private func getPrivateKeys() -> [String] {
        return privateKeysTextView.text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    @objc private func handleEstimate() {
        let contract = contractAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fromAddress = fromAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let toAddress = toAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let privateKeysCount = getPrivateKeys().count
        let permissionId = Int(permissionIdTextField.text ?? "") ?? 2
        
        guard let amount = Double(amountStr), amount > 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        if contract.isEmpty || fromAddress.isEmpty || toAddress.isEmpty || privateKeysCount < 1 {
            showAlert(message: "Please fill all fields and at least one private key count for estimation")
            return
        }
        
        Task {
            estimateButton.isEnabled = false
            resultTextView.text = "Initializing TronWeb for estimation..."
            
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                do {
                    try await tronWeb.setupAsync(privateKey: "01", node: selectedNode)
                    await executeEstimate(contract: contract, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeysCount: privateKeysCount, permissionId: permissionId)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.estimateButton.isEnabled = true
                }
            } else {
                await executeEstimate(contract: contract, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeysCount: privateKeysCount, permissionId: permissionId)
            }
        }
    }
    
    private func executeEstimate(contract: String, fromAddress: String, toAddress: String, amount: Double, privateKeysCount: Int, permissionId: Int) async {
        let response = await self.tronWeb.estimateMultiSigTrc20FeeAsync(contractAddress: contract, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeysCount: privateKeysCount, permissionId: permissionId)
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
        let contract = contractAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fromAddress = fromAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let toAddress = toAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let privateKeys = getPrivateKeys()
        let permissionId = Int(permissionIdTextField.text ?? "") ?? 2
        
        guard let amount = Double(amountStr), amount > 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        if contract.isEmpty || fromAddress.isEmpty || toAddress.isEmpty || privateKeys.isEmpty {
            showAlert(message: "Please fill all fields correctly")
            return
        }
        
        Task {
            transferButton.isEnabled = false
            viewOnExplorerButton.isHidden = true // Hide button on new transfer attempt
            lastTxid = nil
            resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
            
            do {
                // Use first private key for setup
                try await tronWeb.setupAsync(privateKey: privateKeys[0], node: selectedNode)
                await executeTransfer(contract: contract, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeys: privateKeys, permissionId: permissionId)
            } catch {
                self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                self.transferButton.isEnabled = true
            }
        }
    }
    
    private func executeTransfer(contract: String, fromAddress: String, toAddress: String, amount: Double, privateKeys: [String], permissionId: Int) async {
        transferButton.isEnabled = false
        resultTextView.text = "Broadcasting multi-sig TRC20 transaction..."
        
        let response = await tronWeb.multiSigTrc20TransferAsync(contractAddress: contract, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeys: privateKeys, permissionId: permissionId)
        self.transferButton.isEnabled = true
        
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.resultTextView.text = jsonString
            } else {
                self.resultTextView.text = "\(response)"
            }
            
            // Extract txid and show explorer button
            var capturedTxid: String?
            
            // 1. Check nested result structure: response["result"]["txid"]
            if let resultDict = response["result"] as? [String: Any],
               let txid = resultDict["txid"] as? String {
                capturedTxid = txid
            } 
            // 2. Fallback: Check root for txid
            else if let txid = response["txid"] as? String {
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
