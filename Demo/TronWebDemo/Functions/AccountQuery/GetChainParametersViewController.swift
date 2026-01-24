import UIKit
import SnapKit
import TronWeb
class GetChainParametersViewController: UIViewController {

    // MARK: - Properties 
    private let tronWeb = TronWeb()
    private let selectedNode: String
    
    // MARK: - UI Components
    private let networkStatusLabel = UILabel()
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
        self.title = "Chain Parameters"
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

        // Query Button
        queryButton.setTitle("Get Chain Parameters", for: .normal)
        queryButton.backgroundColor = .systemBlue
        queryButton.setTitleColor(.white, for: .normal)
        queryButton.layer.cornerRadius = 8
        queryButton.addTarget(self, action: #selector(handleQuery), for: .touchUpInside)
        view.addSubview(queryButton)
        queryButton.snp.makeConstraints { make in
            make.top.equalTo(networkStatusLabel.snp.bottom).offset(30)
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
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
        Task {
            if tronWeb.isGenerateTronWebInstanceSuccess != true {
                queryButton.isEnabled = false
                resultTextView.text = "Initializing TronWeb on \(selectedNode == TRONMainNet ? "Mainnet" : "Nile Testnet")..."
                
                do {
                    try await tronWeb.setupAsync(node: selectedNode)
                    await executeGetParams()
                } catch {
                    self.resultTextView.text = "TronWeb Setup Failed: \(error.localizedDescription)"
                    self.queryButton.isEnabled = true
                }
            } else {
                await executeGetParams()
            }
        }
    }
    
    private func executeGetParams() async {
        queryButton.isEnabled = false
        resultTextView.text = "Fetching chain parameters..."
        
        let response = await tronWeb.getChainParametersAsync()
        
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
