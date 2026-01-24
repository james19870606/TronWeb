import UIKit
import SnapKit

class GetTRC20BalanceViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String
    
    // MARK: - UI Components
    private let networkStatusLabel = UILabel()
    private let contractLabel = UILabel()
    private let contractTextField = UITextField()
    
    private let addressLabel = UILabel()
    private let addressTextField = UITextField()
    
    private let queryButton = UIButton(type: .system)
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
        self.title = "Get TRC20 Balance"
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

        // Contract Address Input
        contractLabel.text = "Contract Address (e.g. USDT):"
        view.addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        contractTextField.placeholder = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
        contractTextField.text = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t" // Default USDT
        contractTextField.borderStyle = .roundedRect
        contractTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        contractTextField.autocapitalizationType = .none
        contractTextField.autocorrectionType = .no
        view.addSubview(contractTextField)
        contractTextField.snp.makeConstraints { make in
            make.top.equalTo(contractLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Wallet Address Input
        addressLabel.text = "Wallet Address:"
        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(contractTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        addressTextField.placeholder = "T..."
        addressTextField.borderStyle = .roundedRect
        addressTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        addressTextField.autocapitalizationType = .none
        addressTextField.autocorrectionType = .no
        view.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Query Button
        queryButton.setTitle("Query TRC20 Balance", for: .normal)
        queryButton.backgroundColor = .systemBlue
        queryButton.setTitleColor(.white, for: .normal)
        queryButton.layer.cornerRadius = 8
        queryButton.addTarget(self, action: #selector(handleQuery), for: .touchUpInside)
        view.addSubview(queryButton)
        queryButton.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(30)
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
            make.top.equalTo(queryButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
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
    
    @objc private func handleQuery() {
        let contract = contractTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let address = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if contract.isEmpty || address.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please enter both contract and wallet addresses", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                queryButton.isEnabled = false
                resultTextView.text = "Initializing TronWeb on \(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet")..."
                
                do {
                    try await tronWeb.setupAsync(privateKey: "01", node: selectedNode)
                    await executeGetTRC20Balance(contract: contract, address: address)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.queryButton.isEnabled = true
                }
            } else {
                await executeGetTRC20Balance(contract: contract, address: address)
            }
        }
    }
    
    private func executeGetTRC20Balance(contract: String, address: String) async {
        queryButton.isEnabled = false
        resultTextView.text = "Querying TRC20 balance..."
        
        let response = await tronWeb.getTRC20TokenBalanceAsync(contractAddress: contract, address: address)
        
        self.queryButton.isEnabled = true
        
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
