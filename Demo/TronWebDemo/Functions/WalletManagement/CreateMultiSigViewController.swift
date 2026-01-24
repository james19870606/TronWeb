import UIKit
import SnapKit
import SafariServices

class CreateMultiSigViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String
    private var lastTxid: String?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let ownerAddressLabel = UILabel()
    private let ownerAddressTextField = UITextField()
    
    private let privateKeyLabel = UILabel()
    private let privateKeyTextField = UITextField()
    
    private let ownersLabel = UILabel()
    private let ownersTextView = UITextView()
    private let ownersHintLabel = UILabel()
    
    private let requiredLabel = UILabel()
    private let requiredTextField = UITextField()
    
    private let createButton = UIButton(type: .system)
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
        self.title = "Create Multi-Sig"
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

        // Owner Address
        ownerAddressLabel.text = "Account Address (to update):"
        contentView.addSubview(ownerAddressLabel)
        ownerAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        ownerAddressTextField.placeholder = "T..."
        ownerAddressTextField.borderStyle = .roundedRect
        contentView.addSubview(ownerAddressTextField)
        ownerAddressTextField.snp.makeConstraints { make in
            make.top.equalTo(ownerAddressLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Private Key
        privateKeyLabel.text = "Owner Private Key (Hex):"
        contentView.addSubview(privateKeyLabel)
        privateKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(ownerAddressTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        privateKeyTextField.placeholder = "64-digit hex"
        privateKeyTextField.borderStyle = .roundedRect
        privateKeyTextField.isSecureTextEntry = true
        contentView.addSubview(privateKeyTextField)
        privateKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(privateKeyLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Owners List
        ownersLabel.text = "Multi-Sig Owners (One per line):"
        contentView.addSubview(ownersLabel)
        ownersLabel.snp.makeConstraints { make in
            make.top.equalTo(privateKeyTextField.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        ownersTextView.layer.borderColor = UIColor.systemGray4.cgColor
        ownersTextView.layer.borderWidth = 1
        ownersTextView.layer.cornerRadius = 8
        contentView.addSubview(ownersTextView)
        ownersTextView.snp.makeConstraints { make in
            make.top.equalTo(ownersLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        ownersHintLabel.text = "Enter at least 2 addresses"
        ownersHintLabel.font = .systemFont(ofSize: 12)
        ownersHintLabel.textColor = .systemGray
        contentView.addSubview(ownersHintLabel)
        ownersHintLabel.snp.makeConstraints { make in
            make.top.equalTo(ownersTextView.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
        }
        
        // Required Threshold
        requiredLabel.text = "Threshold (Required Signatures):"
        contentView.addSubview(requiredLabel)
        requiredLabel.snp.makeConstraints { make in
            make.top.equalTo(ownersHintLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        
        requiredTextField.placeholder = "e.g. 2"
        requiredTextField.borderStyle = .roundedRect
        requiredTextField.keyboardType = .numberPad
        contentView.addSubview(requiredTextField)
        requiredTextField.snp.makeConstraints { make in
            make.top.equalTo(requiredLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
        // Create Button
        createButton.setTitle("Create Multi-Sig Address", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.addTarget(self, action: #selector(handleCreate), for: .touchUpInside)
        contentView.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(requiredTextField.snp.bottom).offset(30)
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
            make.top.equalTo(createButton.snp.bottom).offset(20)
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

    @objc private func handleCreate() {
        let ownerAddress = ownerAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let privateKey = privateKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let ownersText = ownersTextView.text ?? ""
        let owners = ownersText.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let required = Int(requiredTextField.text ?? "") ?? 0

        if ownerAddress.isEmpty || privateKey.isEmpty || owners.count < 2 || required < 1 {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields correctly. At least 2 owners required.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                createButton.isEnabled = false
                viewOnExplorerButton.isHidden = true
                lastTxid = nil
                resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
                
                do {
                    try await tronWeb.setupAsync(privateKey: privateKey, node: selectedNode)
                    await executeCreateMultiSig(ownerAddress: ownerAddress, owners: owners, required: required, privateKey: privateKey)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.createButton.isEnabled = true
                }
            } else {
                await executeCreateMultiSig(ownerAddress: ownerAddress, owners: owners, required: required, privateKey: privateKey)
            }
        }
    }
    
    private func executeCreateMultiSig(ownerAddress: String, owners: [String], required: Int, privateKey: String) async {
        createButton.isEnabled = false
        resultTextView.text = "Creating Multi-Sig address... (This may cost 100 TRX)"
        
        let response = await tronWeb.createMultiSigAddressAsync(ownerAddress: ownerAddress, owners: owners, required: required, privateKey: privateKey)
        self.createButton.isEnabled = true
        
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.resultTextView.text = jsonString
            } else {
                self.resultTextView.text = "\(response)"
            }
            
            // Extract txid and show explorer button
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
    
    @objc private func handleCopy() {
        guard let text = resultTextView.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        let alert = UIAlertController(title: "Success", message: "Result copied to clipboard", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
