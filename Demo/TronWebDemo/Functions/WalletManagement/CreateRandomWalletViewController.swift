import UIKit
import SnapKit

class CreateRandomWalletViewController: UIViewController {
    
    // MARK: - Properties
    private let tronWeb = TronWeb()
    private let selectedNode: String
    
    // MARK: - UI Components
    private let networkStatusLabel = UILabel()
    private let wordCountLabel = UILabel()
    private let wordCountSegment = UISegmentedControl(items: ["12", "15", "18", "21", "24"])
    
    private let languageLabel = UILabel()
    private let languageButton = UIButton(type: .system)
    
    private let createButton = UIButton(type: .system)
    private let resultTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    
    private let languages = [
        "english", "chinese_simplified", "chinese_traditional",
        "japanese", "korean", "french", "italian",
        "spanish", "portuguese", "czech"
    ]
    private var selectedLanguage = "english"

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
        self.title = "Create Random Wallet"
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

        // Word Count
        wordCountLabel.text = "Mnemonic Word Count:"
        view.addSubview(wordCountLabel)
        wordCountLabel.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        wordCountSegment.selectedSegmentIndex = 0
        view.addSubview(wordCountSegment)
        wordCountSegment.snp.makeConstraints { make in
            make.top.equalTo(wordCountLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Language
        languageLabel.text = "Language:"
        view.addSubview(languageLabel)
        languageLabel.snp.makeConstraints { make in
            make.top.equalTo(wordCountSegment.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        languageButton.setTitle("english", for: .normal)
        languageButton.contentHorizontalAlignment = .left
        languageButton.addTarget(self, action: #selector(showLanguagePicker), for: .touchUpInside)
        view.addSubview(languageButton)
        languageButton.snp.makeConstraints { make in
            make.top.equalTo(languageLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Create Button
        createButton.setTitle("Create Wallet", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.addTarget(self, action: #selector(handleCreateWallet), for: .touchUpInside)
        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(languageButton.snp.bottom).offset(30)
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
            make.top.equalTo(createButton.snp.bottom).offset(20)
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

    @objc private func showLanguagePicker() {
        let alert = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        for lang in languages {
            alert.addAction(UIAlertAction(title: lang, style: .default, handler: { _ in
                self.selectedLanguage = lang
                self.languageButton.setTitle(lang, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func handleCreateWallet() {
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                do {
                    try await tronWeb.setupAsync(node: selectedNode)
                    await executeCreateWallet()
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.createButton.isEnabled = true
                }
            } else {
                await executeCreateWallet()
            }
        }
    }
    
    private func executeCreateWallet() async {
        let wordCountString = wordCountSegment.titleForSegment(at: wordCountSegment.selectedSegmentIndex) ?? "12"
        let wordCount = Int(wordCountString) ?? 12
        
        createButton.isEnabled = false
        resultTextView.text = "Creating wallet..."
        
        let response = await tronWeb.createRandomAsync(wordCount: wordCount, language: selectedLanguage)
        
        self.createButton.isEnabled = true
        
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
