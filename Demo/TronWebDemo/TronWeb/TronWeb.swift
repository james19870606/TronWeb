//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import WebKit
public let TRONMainNet: String = "https://api.trongrid.io"
public let TRONNileNet: String = "https://nile.trongrid.io"
public let TRONApiKey: String = "188434ac-470f-494e-8241-830ed5cb00fc"

@MainActor
public class TronWeb: NSObject {
    var webView: WKWebView!
    var bridge: WKWebViewJavascriptBridge!
    public var isGenerateTronWebInstanceSuccess: Bool = false
    var onCompleted: ((Bool, String) -> Void)?
    var showLog: Bool = true
    public var currentNode: String = TRONNileNet // Track current node
    override public init() {
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.bridge = WKWebViewJavascriptBridge(webView: self.webView, isHookConsole: false)
    }

    deinit {
        print("\(type(of: self)) release")
    }

    public func setup(showLog: Bool = true, privateKey: String? = "", apiKey: String? = TRONApiKey, node: String = TRONNileNet, onCompleted: ((Bool, String) -> Void)? = nil) {
        self.onCompleted = onCompleted
        self.showLog = showLog
        self.currentNode = node // Update current node
        #if !DEBUG
        self.showLog = false
        #endif
        self.bridge.register(handlerName: "FinishLoad") { [weak self] _, _ in
            guard let self = self else { return }
            self.generateTronWebInstance(privateKey: privateKey, apiKey: apiKey, node: node)
        }
        if let url = TronResourceLoader.url(name: "index", ext: "html", subdirectory: "TronWeb.bundle") {
            self.webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }

    /// Async version of setup
    public func setupAsync(showLog: Bool = true, privateKey: String? = "01", apiKey: String? = TRONApiKey, node: String = TRONNileNet) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task { @MainActor in
                self.setup(showLog: showLog, privateKey: privateKey, apiKey: apiKey, node: node) { success, error in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NSError(domain: "TronWeb", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    }
                }
            }
        }
    }


    func generateTronWebInstance(privateKey: String?, apiKey: String? = TRONApiKey, node: String = TRONNileNet) {
        let params = ["privateKey": privateKey, "node": node, "apiKey": apiKey]
        self.bridge.call(handlerName: "generateTronWebInstance", data: params) { [weak self] response in
            guard let self = self, let temp = response as? [String: Any] else {
                self?.onCompleted?(false, "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state {
                self.isGenerateTronWebInstanceSuccess = true
                self.onCompleted?(state, "")
            } else if let error = temp["error"] as? String {
                self.isGenerateTronWebInstanceSuccess = false
                self.onCompleted?(false, error)
            } else {
                self.isGenerateTronWebInstanceSuccess = false
                self.onCompleted?(false, "Unknown response format")
            }
        }
    }

    // MARK: - Wallet Management
    public func createRandom(wordCount: Int = 12, language: String = "english", completion: @escaping ([String: Any]?) -> Void) {
        let params = ["wordCount": wordCount, "language": language] as [String : Any]
        self.bridge.call(handlerName: "createRandom", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of createRandom
    public func createRandomAsync(wordCount: Int = 12, language: String = "english") async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.createRandom(wordCount: wordCount, language: language) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func importAccountFromMnemonic(mnemonic: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["mnemonic": mnemonic]
        self.bridge.call(handlerName: "importAccountFromMnemonic", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of importAccountFromMnemonic
    public func importAccountFromMnemonicAsync(mnemonic: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.importAccountFromMnemonic(mnemonic: mnemonic) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func importAccountFromPrivateKey(privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["privateKey": privateKey]
        self.bridge.call(handlerName: "importAccountFromPrivateKey", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of importAccountFromPrivateKey
    public func importAccountFromPrivateKeyAsync(privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.importAccountFromPrivateKey(privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func resetTronWebPrivateKey(privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["privateKey": privateKey]
        self.bridge.call(handlerName: "resetTronWebPrivateKey", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of resetTronWebPrivateKey
    public func resetTronWebPrivateKeyAsync(privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.resetTronWebPrivateKey(privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func createMultiSigAddress(ownerAddress: String, owners: [String], required: Int, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "ownerAddress": ownerAddress,
            "owners": owners,
            "required": required,
            "privateKey": privateKey
        ]
        self.bridge.call(handlerName: "createMultiSigAddress", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of createMultiSigAddress
    public func createMultiSigAddressAsync(ownerAddress: String, owners: [String], required: Int, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.createMultiSigAddress(ownerAddress: ownerAddress, owners: owners, required: required, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    // MARK: - Account Query
    public func getAccount(address: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["address": address]
        self.bridge.call(handlerName: "getAccount", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getAccount
    public func getAccountAsync(address: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getAccount(address: address) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func getTRXBalance(address: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["address": address]
        self.bridge.call(handlerName: "getTRXBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getTRXBalance
    public func getTRXBalanceAsync(address: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getTRXBalance(address: address) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func getTRC20TokenBalance(contractAddress: String, address: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["contractAddress": contractAddress, "address": address]
        self.bridge.call(handlerName: "getTRC20TokenBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getTRC20TokenBalance
    public func getTRC20TokenBalanceAsync(contractAddress: String, address: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getTRC20TokenBalance(contractAddress: contractAddress, address: address) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func getAccountResources(address: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["address": address]
        self.bridge.call(handlerName: "getAccountResources", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getAccountResources
    public func getAccountResourcesAsync(address: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getAccountResources(address: address) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func getChainParameters(completion: @escaping ([String: Any]?) -> Void) {
        self.bridge.call(handlerName: "getChainParameters", data: nil) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of getChainParameters
    public func getChainParametersAsync() async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.getChainParameters { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    // MARK: - Message Signing & Verification
    public func signMessageV2(message: String, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["message": message, "privateKey": privateKey]
        self.bridge.call(handlerName: "signMessageV2", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of signMessageV2
    public func signMessageV2Async(message: String, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.signMessageV2(message: message, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func verifyMessageV2(message: String, signature: String, address: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["message": message, "signature": signature, "address": address]
        self.bridge.call(handlerName: "verifyMessageV2", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of verifyMessageV2
    public func verifyMessageV2Async(message: String, signature: String, address: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.verifyMessageV2(message: message, signature: signature, address: address) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    // MARK: - Transaction Operations
    public func trxTransfer(toAddress: String, amount: Double, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["toAddress": toAddress, "amount": amount, "privateKey": privateKey] as [String : Any]
        self.bridge.call(handlerName: "trxTransfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of trxTransfer
    public func trxTransferAsync(toAddress: String, amount: Double, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.trxTransfer(toAddress: toAddress, amount: amount, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func trc20Transfer(contractAddress: String, toAddress: String, amount: Double, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "contractAddress": contractAddress,
            "toAddress": toAddress,
            "amount": amount,
            "privateKey": privateKey
        ] as [String : Any]
        self.bridge.call(handlerName: "trc20Transfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of trc20Transfer
    public func trc20TransferAsync(contractAddress: String, toAddress: String, amount: Double, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.trc20Transfer(contractAddress: contractAddress, toAddress: toAddress, amount: amount, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func estimateTrxFee(toAddress: String, amount: Double, fromAddress: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = ["toAddress": toAddress, "amount": amount, "fromAddress": fromAddress] as [String : Any]
        self.bridge.call(handlerName: "estimateTrxFee", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimateTrxFee
    public func estimateTrxFeeAsync(toAddress: String, amount: Double, fromAddress: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimateTrxFee(toAddress: toAddress, amount: amount, fromAddress: fromAddress) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func estimateTrc20Fee(contractAddress: String, toAddress: String, amount: Double, fromAddress: String, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "contractAddress": contractAddress,
            "toAddress": toAddress,
            "amount": amount,
            "fromAddress": fromAddress
        ] as [String : Any]
        self.bridge.call(handlerName: "estimateTrc20Fee", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimateTrc20Fee
    public func estimateTrc20FeeAsync(contractAddress: String, toAddress: String, amount: Double, fromAddress: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimateTrc20Fee(contractAddress: contractAddress, toAddress: toAddress, amount: amount, fromAddress: fromAddress) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func multiSigTrxTransfer(fromAddress: String, toAddress: String, amount: Double, privateKeys: [String], permissionId: Int = 2, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "fromAddress": fromAddress,
            "toAddress": toAddress,
            "amount": amount,
            "privateKeys": privateKeys,
            "permissionId": permissionId
        ] as [String : Any]
        self.bridge.call(handlerName: "multiSigTrxTransfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of multiSigTrxTransfer
    public func multiSigTrxTransferAsync(fromAddress: String, toAddress: String, amount: Double, privateKeys: [String], permissionId: Int = 2) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.multiSigTrxTransfer(fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeys: privateKeys, permissionId: permissionId) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func estimateMultiSigTrxFee(fromAddress: String, toAddress: String, amount: Double, privateKeysCount: Int, permissionId: Int = 2, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "fromAddress": fromAddress,
            "toAddress": toAddress,
            "amount": amount,
            "privateKeysCount": privateKeysCount,
            "permissionId": permissionId
        ] as [String : Any]
        self.bridge.call(handlerName: "estimateMultiSigTrxFee", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimateMultiSigTrxFee
    public func estimateMultiSigTrxFeeAsync(fromAddress: String, toAddress: String, amount: Double, privateKeysCount: Int, permissionId: Int = 2) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimateMultiSigTrxFee(fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeysCount: privateKeysCount, permissionId: permissionId) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func multiSigTrc20Transfer(contractAddress: String, fromAddress: String, toAddress: String, amount: Double, privateKeys: [String], permissionId: Int = 2, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "contractAddress": contractAddress,
            "fromAddress": fromAddress,
            "toAddress": toAddress,
            "amount": amount,
            "privateKeys": privateKeys,
            "permissionId": permissionId
        ] as [String : Any]
        self.bridge.call(handlerName: "multiSigTrc20Transfer", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of multiSigTrc20Transfer
    public func multiSigTrc20TransferAsync(contractAddress: String, fromAddress: String, toAddress: String, amount: Double, privateKeys: [String], permissionId: Int = 2) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.multiSigTrc20Transfer(contractAddress: contractAddress, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeys: privateKeys, permissionId: permissionId) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func estimateMultiSigTrc20Fee(contractAddress: String, fromAddress: String, toAddress: String, amount: Double, privateKeysCount: Int, permissionId: Int = 2, completion: @escaping ([String: Any]?) -> Void) {
        let params = [
            "contractAddress": contractAddress,
            "fromAddress": fromAddress,
            "toAddress": toAddress,
            "amount": amount,
            "privateKeysCount": privateKeysCount,
            "permissionId": permissionId
        ] as [String : Any]
        self.bridge.call(handlerName: "estimateMultiSigTrc20Fee", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of estimateMultiSigTrc20Fee
    public func estimateMultiSigTrc20FeeAsync(contractAddress: String, fromAddress: String, toAddress: String, amount: Double, privateKeysCount: Int, permissionId: Int = 2) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.estimateMultiSigTrc20Fee(contractAddress: contractAddress, fromAddress: fromAddress, toAddress: toAddress, amount: amount, privateKeysCount: privateKeysCount, permissionId: permissionId) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func freezeBalance(amount: Double, resourceType: String, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "amount": amount,
            "resourceType": resourceType,
            "privateKey": privateKey
        ]
        self.bridge.call(handlerName: "freezeBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of freezeBalance
    public func freezeBalanceAsync(amount: Double, resourceType: String, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.freezeBalance(amount: amount, resourceType: resourceType, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func unfreezeBalance(amount: Double, resourceType: String, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "amount": amount,
            "resourceType": resourceType,
            "privateKey": privateKey
        ]
        self.bridge.call(handlerName: "unfreezeBalance", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of unfreezeBalance
    public func unfreezeBalanceAsync(amount: Double, resourceType: String, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.unfreezeBalance(amount: amount, resourceType: resourceType, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }

    public func delegateResource(amount: Double, resourceType: String, receiverAddress: String, privateKey: String, completion: @escaping ([String: Any]?) -> Void) {
        let params: [String: Any] = [
            "amount": amount,
            "resourceType": resourceType,
            "receiverAddress": receiverAddress,
            "privateKey": privateKey
        ]
        self.bridge.call(handlerName: "delegateResource", data: params) { response in
            completion(response as? [String: Any])
        }
    }

    /// Async version of delegateResource
    public func delegateResourceAsync(amount: Double, resourceType: String, receiverAddress: String, privateKey: String) async -> [String: Any]? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                self.delegateResource(amount: amount, resourceType: resourceType, receiverAddress: receiverAddress, privateKey: privateKey) { response in
                    continuation.resume(returning: response)
                }
            }
        }
    }
}
