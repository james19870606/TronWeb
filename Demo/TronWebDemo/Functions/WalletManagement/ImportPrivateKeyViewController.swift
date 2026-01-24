import UIKit
import SnapKit

class ImportPrivateKeyViewController: UIViewController {

    // MARK: - Properties
    private let tronWeb = TronWeb()
    private let selectedNode: String
    
    // MARK: - UI Components
    private let networkStatusLabel = UILabel()
    private let privateKeyLabel = UILabel()
    private let privateKeyTextField = UITextField()
    
    private let importButton = UIButton(type: .system)
    private let resultTextView = UITextView()
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
        self.title = "Import from Private Key"
        setupUI()
        updateNetworkStatus()
    }
    
    private func setupUI() {
        // Network Status
        networkStatusLabel.textAlignment = .center
        networkStatusLabel.font = .systemFont(ofSize: 14, weight: .bold)
        networkStatusLabel.layer.cornerRadius = 4
        networkStatusLabel.layer.masksToBounds = true
        view.addSubview(networkStatusLabel)
        networkStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }

        // Private Key Input
        privateKeyLabel.text = "Enter Private Key (Hex):"
        view.addSubview(privateKeyLabel)
        privateKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        privateKeyTextField.placeholder = "64-digit hex string"
        privateKeyTextField.borderStyle = .roundedRect
        privateKeyTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        privateKeyTextField.autocapitalizationType = .none
        privateKeyTextField.autocorrectionType = .no
        view.addSubview(privateKeyTextField)
        privateKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(privateKeyLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Import Button
        importButton.setTitle("Import Wallet", for: .normal)
        importButton.backgroundColor = .systemBlue
        importButton.setTitleColor(.white, for: .normal)
        importButton.layer.cornerRadius = 8
        importButton.addTarget(self, action: #selector(handleImport), for: .touchUpInside)
        view.addSubview(importButton)
        importButton.snp.makeConstraints { make in
            make.top.equalTo(privateKeyTextField.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Result TextView
        resultTextView.isEditable = false
        resultTextView.layer.borderColor = UIColor.systemGray4.cgColor
        resultTextView.layer.borderWidth = 1
        resultTextView.layer.cornerRadius = 8
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        view.addSubview(resultTextView)
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(importButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(250)
        }
        
        // Copy Button
        copyButton.setTitle("Copy JSON Result", for: .normal)
        copyButton.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        view.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.top.equalTo(resultTextView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
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
    
    @objc private func handleImport() {
        let privateKey = privateKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if privateKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter your private key", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                importButton.isEnabled = false
                resultTextView.text = "Initializing TronWeb..."
                
                do {
                    try await tronWeb.setupAsync(privateKey: "01", node: selectedNode)
                    await executeImport(privateKey: privateKey)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.importButton.isEnabled = true
                }
            } else {
                await executeImport(privateKey: privateKey)
            }
        }
    }
    
    private func executeImport(privateKey: String) async {
        importButton.isEnabled = false
        resultTextView.text = "Importing wallet..."
        
        let response = await tronWeb.importAccountFromPrivateKeyAsync(privateKey: privateKey)
        
        self.importButton.isEnabled = true
        
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.resultTextView.text = jsonString
            } else {
                self.resultTextView.text = "\(response)"
            }
        } else {
            self.resultTextView.text = "Failed to receive response from TronWeb"
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
