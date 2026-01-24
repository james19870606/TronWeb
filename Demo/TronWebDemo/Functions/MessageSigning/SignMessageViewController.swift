import UIKit
import SnapKit
import TronWeb
class SignMessageViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let messageLabel = UILabel()
    private let messageTextView = UITextView()
    
    private let privateKeyLabel = UILabel()
    private let privateKeyTextField = UITextField()
    
    private let signButton = UIButton(type: .system)
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
        self.title = "Sign Message V2"
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

        // Message Input
        messageLabel.text = "Message to Sign (Plaintext):"
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        messageTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 8
        messageTextView.font = .systemFont(ofSize: 16)
        contentView.addSubview(messageTextView)
        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        // Private Key Input
        privateKeyLabel.text = "Private Key (Hex):"
        contentView.addSubview(privateKeyLabel)
        privateKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(20)
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
        
        // Sign Button
        signButton.setTitle("Sign Message", for: .normal)
        signButton.backgroundColor = .systemBlue
        signButton.setTitleColor(.white, for: .normal)
        signButton.layer.cornerRadius = 8
        signButton.addTarget(self, action: #selector(handleSign), for: .touchUpInside)
        contentView.addSubview(signButton)
        signButton.snp.makeConstraints { make in
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
            make.top.equalTo(signButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        copyButton.setTitle("Copy JSON Result", for: .normal)
        copyButton.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        contentView.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.top.equalTo(resultTextView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
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

    @objc private func handleSign() {
        let message = messageTextView.text ?? ""
        let privateKey = privateKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if message.isEmpty || privateKey.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please fill both message and private key", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                signButton.isEnabled = false
                resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
                
                do {
                    try await tronWeb.setupAsync(privateKey: privateKey, node: selectedNode)
                    await executeSign(message: message, privateKey: privateKey)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.signButton.isEnabled = true
                }
            } else {
                await executeSign(message: message, privateKey: privateKey)
            }
        }
    }
    
    private func executeSign(message: String, privateKey: String) async {
        signButton.isEnabled = false
        resultTextView.text = "Signing message..."
        
        let response = await tronWeb.signMessageV2Async(message: message, privateKey: privateKey)
        
        self.signButton.isEnabled = true
        
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
