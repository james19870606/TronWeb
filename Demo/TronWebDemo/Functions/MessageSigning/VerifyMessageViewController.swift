import UIKit
import SnapKit
import TronWeb
class VerifyMessageViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let networkStatusLabel = UILabel()
    
    private let messageLabel = UILabel()
    private let messageTextView = UITextView()
    
    private let signatureLabel = UILabel()
    private let signatureTextView = UITextView()
    
    private let addressLabel = UILabel()
    private let addressTextField = UITextField()
    
    private let verifyButton = UIButton(type: .system)
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
        self.title = "Verify Message V2"
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
        messageLabel.text = "Original Message:"
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
            make.height.equalTo(80)
        }
        
        // Signature Input
        signatureLabel.text = "Signature (Hex):"
        contentView.addSubview(signatureLabel)
        signatureLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        signatureTextView.layer.borderColor = UIColor.systemGray4.cgColor
        signatureTextView.layer.borderWidth = 1
        signatureTextView.layer.cornerRadius = 8
        signatureTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        contentView.addSubview(signatureTextView)
        signatureTextView.snp.makeConstraints { make in
            make.top.equalTo(signatureLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        // Address Input
        addressLabel.text = "Expected Signer Address:"
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(signatureTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        addressTextField.placeholder = "T..."
        addressTextField.borderStyle = .roundedRect
        addressTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        addressTextField.autocapitalizationType = .none
        addressTextField.autocorrectionType = .no
        contentView.addSubview(addressTextField)
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Verify Button
        verifyButton.setTitle("Verify Signature", for: .normal)
        verifyButton.backgroundColor = .systemBlue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 8
        verifyButton.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        contentView.addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(30)
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
            make.top.equalTo(verifyButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(150)
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

    @objc private func handleVerify() {
        let message = messageTextView.text ?? ""
        let signature = signatureTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let address = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if message.isEmpty || signature.isEmpty || address.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                verifyButton.isEnabled = false
                resultTextView.text = "Initializing TronWeb (\(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet"))..."
                
                do {
                    try await tronWeb.setupAsync(privateKey: "01", node: selectedNode)
                    await executeVerify(message: message, signature: signature, address: address)
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.verifyButton.isEnabled = true
                }
            } else {
                await executeVerify(message: message, signature: signature, address: address)
            }
        }
    }
    
    private func executeVerify(message: String, signature: String, address: String) async {
        verifyButton.isEnabled = false
        resultTextView.text = "Verifying signature..."
        
        let response = await tronWeb.verifyMessageV2Async(message: message, signature: signature, address: address)
        
        self.verifyButton.isEnabled = true
        
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
