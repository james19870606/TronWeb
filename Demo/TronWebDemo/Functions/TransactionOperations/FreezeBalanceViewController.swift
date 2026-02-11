import UIKit
import SnapKit
import SafariServices

class FreezeBalanceViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String
    private var lastTxid: String?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let amountLabel = UILabel()
    private let amountTextField = UITextField()
    
    private let resourceTypeLabel = UILabel()
    private let resourceTypeSegment = UISegmentedControl(items: ["ENERGY", "BANDWIDTH"])
    
    private let privateKeyLabel = UILabel()
    private let privateKeyTextField = UITextField()
    
    private let freezeButton = UIButton(type: .system)
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
        self.title = "Freeze TRX (Stake 2.0)"
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
        
        // Amount
        amountLabel.text = "Amount to Freeze (TRX):"
        contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        amountTextField.placeholder = "Min 1 TRX"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        contentView.addSubview(amountTextField)
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Resource Type
        resourceTypeLabel.text = "Obtain Resource Type:"
        contentView.addSubview(resourceTypeLabel)
        resourceTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        resourceTypeSegment.selectedSegmentIndex = 0
        contentView.addSubview(resourceTypeSegment)
        resourceTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(resourceTypeLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Private Key
        privateKeyLabel.text = "Owner Private Key (Hex):"
        contentView.addSubview(privateKeyLabel)
        privateKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(resourceTypeSegment.snp.bottom).offset(15)
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
        
        // Freeze Button
        freezeButton.setTitle("Freeze TRX", for: .normal)
        freezeButton.backgroundColor = .systemBlue
        freezeButton.setTitleColor(.white, for: .normal)
        freezeButton.layer.cornerRadius = 8
        freezeButton.addTarget(self, action: #selector(handleFreeze), for: .touchUpInside)
        contentView.addSubview(freezeButton)
        freezeButton.snp.makeConstraints { make in
            make.top.equalTo(privateKeyTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
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
            make.top.equalTo(freezeButton.snp.bottom).offset(20)
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

    @objc private func handleFreeze() {
        let amountStr = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resourceType = resourceTypeSegment.selectedSegmentIndex == 0 ? "ENERGY" : "BANDWIDTH"
        let privateKey = privateKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard let amount = Double(amountStr), amount > 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        if privateKey.isEmpty {
            showAlert(message: "Please enter your private key")
            return
        }
        
        Task {
            freezeButton.isEnabled = false
            viewOnExplorerButton.isHidden = true
            lastTxid = nil
            resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
            
            do {
                try await tronWeb.setupAsync(privateKey: privateKey, node: selectedNode)
                await executeFreeze(amount: amount, resourceType: resourceType, privateKey: privateKey)
            } catch {
                self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                self.freezeButton.isEnabled = true
            }
        }
    }
    
    private func executeFreeze(amount: Double, resourceType: String, privateKey: String) async {
        freezeButton.isEnabled = false
        resultTextView.text = "Staking TRX..."
        
        let response = await tronWeb.freezeBalanceAsync(amount: amount, resourceType: resourceType, privateKey: privateKey)
        self.freezeButton.isEnabled = true
        
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
