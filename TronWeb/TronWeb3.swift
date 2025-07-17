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
extension TronWeb3: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.showLog { print("didFinish") }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if self.showLog { print("error = \(error)") }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.showLog { print("didStartProvisionalNavigation ") }
    }
}

public class TronWeb3: NSObject {
    var webView: WKWebView!
    var bridge: WKWebViewJavascriptBridge!
    public var isGenerateTronWebInstanceSuccess: Bool = false
    var onCompleted: ((Bool, String) -> Void)?
    var showLog: Bool = true
    override public init() {
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.bridge = WKWebViewJavascriptBridge(webView: self.webView, isHookConsole: false)
    }

    deinit {
        print("\(type(of: self)) release")
    }

    public func setup(showLog: Bool = true, privateKey: String? = "", apiKey: String? = TRONApiKey, node: String = TRONNileNet, onCompleted: ((Bool, String) -> Void)? = nil) {
        self.onCompleted = onCompleted
        self.showLog = showLog
        #if !DEBUG
        self.showLog = false
        #endif
        self.bridge.register(handlerName: "FinishLoad") { [weak self] _, _ in
            guard let self = self else { return }
            self.generateTronWebInstance(privateKey: privateKey, apiKey: apiKey, node: node)
        }
        let htmlSource = self.loadBundleResource(bundleName: "TronWeb", sourceName: "/TronIndex.html")
        let url = URL(fileURLWithPath: htmlSource)
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
    }

    func loadBundleResource(bundleName: String, sourceName: String) -> String {
        var bundleResourcePath = Bundle.main.path(forResource: "Frameworks/\(bundleName).framework/\(bundleName)", ofType: "bundle")
        if bundleResourcePath == nil {
            bundleResourcePath = Bundle.main.path(forResource: bundleName, ofType: "bundle") ?? ""
        }
        return bundleResourcePath! + sourceName
    }

    func generateTronWebInstance(privateKey: String?, apiKey: String? = TRONApiKey, node: String = TRONNileNet) {
        let params = ["privateKey": privateKey, "node": node, "apiKey": apiKey]
        self.bridge.call(handlerName: "generateTronWebInstance", data: params) { [weak self] response in
            guard let self = self, let temp = response as? [String: Any] else {
                self?.onCompleted?(false, "Invalid response format")
                return
            }
            if self.showLog { print("response = \(String(describing: response))") }
            if let state = temp["state"] as? Bool, state {
                self.isGenerateTronWebInstanceSuccess = true
                onCompleted?(state, "")
            } else if let error = temp["error"] as? String {
                self.isGenerateTronWebInstanceSuccess = false
                onCompleted?(false, error)
            } else {
                self.isGenerateTronWebInstanceSuccess = false
                onCompleted?(false, "Unknown response format")
            }
        }
    }

    public func tronWebResetPrivateKey(privateKey: String, onCompleted: ((Bool) -> Void)? = nil) {
        let params: [String: String] = ["privateKey": privateKey]
        self.bridge.call(handlerName: "resetPrivateKey", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let response = response as? [String: Bool] else {
                onCompleted?(false)
                return
            }
            if let result = response["result"] {
                onCompleted?(result)
            } else {
                onCompleted?(false)
            }
        }
    }

    // MARK: 獲取trx餘額

    public func getRTXBalance(address: String, onCompleted: ((Bool, String, String) -> Void)? = nil) {
        let params: [String: String] = ["address": address]
        self.bridge.call(handlerName: "getTRXBalance", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let balance = temp["result"] as? String
            {
                onCompleted?(state, balance, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else {
                onCompleted?(false, "", "Unknown response format")
            }
        }
    }

    // MARK: 獲取trc20代幣餘額

    public func getTRC20TokenBalance(address: String,
                                     trc20ContractAddress: String,
                                     decimalPoints: Double,
                                     onCompleted: ((Bool, String, String) -> Void)? = nil)
    {
        let params: [String: Any] = ["address": address,
                                     "trc20ContractAddress": trc20ContractAddress,
                                     "decimalPoints": decimalPoints]
        self.bridge.call(handlerName: "getTRC20TokenBalance", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let balance = temp["result"] as? String
            {
                onCompleted?(state, balance, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else {
                onCompleted?(false, "", "Unknown response format")
            }
        }
    }

    // MARK: trx轉帳 支持備註版本

    public func trxTransferWithRemark(remark: String,
                                      toAddress: String,
                                      amount: String,
                                      onCompleted: ((Bool, String, String) -> Void)? = nil)
    {
        let number = Int64(doubleValue(string: amount) * pow(10, 6))
        let params: [String: Any] = ["toAddress": toAddress,
                                     "amount": number,
                                     "remark": remark]
        self.bridge.call(handlerName: "trxTransferWithRemark", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }

            if let state = temp["result"] as? Bool, state,
               let txid = temp["txid"] as? String
            {
                onCompleted?(state, txid, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else if let code = temp["code"] as? String, let txid = temp["txid"] as? String {
                onCompleted?(false, txid, code)
            } else {
                onCompleted?(false, "", "Unknown response format")
            }
        }
    }

    // MARK: trx轉帳 不支持備註版本

    public func trxTransfer(toAddress: String,
                            amount: String,
                            onCompleted: ((Bool, String, String) -> Void)? = nil)
    {
        let params: [String: String] = ["toAddress": toAddress,
                                        "amount": amount]
        self.bridge.call(handlerName: "trxTransfer", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }

            if let state = temp["result"] as? Bool, state,
               let txid = temp["txid"] as? String
            {
                onCompleted?(state, txid, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else if let code = temp["code"] as? String, let txid = temp["txid"] as? String {
                onCompleted?(false, txid, code)
            } else {
                onCompleted?(false, "", "Unknown response format")
            }
        }
    }

    // MARK: trc20代幣轉帳

    public func trc20TokenTransfer(toAddress: String,
                                   trc20ContractAddress: String,
                                   amount: String,
                                   decimalPoints: Double = 6,
                                   remark: String,
                                   feeLimit: String = "100000000",
                                   onCompleted: ((Bool, String, String) -> Void)? = nil)
    {
        let number = Int64(doubleValue(string: amount) * pow(10, decimalPoints))
        let params: [String: Any] = ["trc20ContractAddress": trc20ContractAddress,
                                     "toAddress": toAddress,
                                     "amount": number,
                                     "feeLimit": feeLimit,
                                     "remark": remark]
        self.bridge.call(handlerName: "tokenTransfer", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }

            if let state = temp["result"] as? Bool, state,
               let txid = temp["txid"] as? String
            {
                onCompleted?(state, txid, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else if let code = temp["code"] as? String, let txid = temp["txid"] as? String {
                onCompleted?(false, txid, code)
            } else {
                onCompleted?(false, "", "Unknown response format")
            }
        }
    }

    // MARK: trc20代幣轉帳estimateEnergy

    public func estimateEnergy(url: String, toAddress: String,
                               trc20ContractAddress: String,
                               amount: String,
                               onCompleted: ((Bool, [String: Any], String) -> Void)? = nil)
    {
        let params: [String: Any] = ["url": url,
                                     "contractAddress": trc20ContractAddress,
                                     "toAddress": toAddress,
                                     "amount": amount]
        self.bridge.call(handlerName: "estimateEnergy", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, [:], "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let feeDic = temp["result"] as? [String: Any]
            {
                onCompleted?(state, feeDic, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, [:], error)
            } else {
                onCompleted?(false, [:], "Unknown response format")
            }
        }
    }

    // MARK: trx轉帳estimate Fee

    public func estimateTRXTransferFee(toAddress: String,
                                       amount: String,
                                       note: String = "",
                                       onCompleted: ((Bool, [String: Any], [String: Any], String) -> Void)? = nil)
    {
        let params: [String: Any] = ["note": note,
                                     "toAddress": toAddress,
                                     "amount": amount]
        self.bridge.call(handlerName: "estimateTRXFee", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, [:], [:], "Invalid response format")
                return
            }

            if let state = temp["state"] as? Bool, state,
               let sendAccountResources = temp["sendAccountResources"] as? [String: Any],
               let feeDic = temp["result"] as? [String: Any]
            {
                onCompleted?(state, sendAccountResources, feeDic, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, [:], [:], error)
            } else {
                onCompleted?(false, [:], [:], "Unknown response format")
            }
        }
    }

    // MARK: 校驗是否是TRX的地址

    public func isTRXAddress(address: String, onCompleted: ((Bool) -> Void)? = nil) {
        let params: [String: String] = ["address": address]
        self.bridge.call(handlerName: "isTRXAddress", data: params) { response in
            guard let isTRXAddress = response as? Bool else {
                onCompleted?(false)
                return
            }
            onCompleted?(isTRXAddress)
        }
    }

    // MARK: 根據地址獲取帳戶資訊

    public func getAccount(address: String, onCompleted: (([String: Any]) -> Void)? = nil) {
        let params: [String: String] = ["address": address]
        self.bridge.call(handlerName: "getAccount", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let data = response as? [String: Any] else {
                onCompleted?([:])
                return
            }
            onCompleted?(data)
        }
    }

    // MARK: getChainParameters

    public func getChainParameters(onCompleted: ((Bool, [[String: Any]], String) -> Void)? = nil) {
        self.bridge.call(handlerName: "getChainParameters") { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, [[:]], "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let result = temp["result"] as? [[String: Any]]
            {
                onCompleted?(state, result, "")
            } else {
                onCompleted?(false, [[:]], "Invalid response format")
            }
        }
    }

    // MARK: getAccountResources

    public func getAccountResources(address: String, onCompleted: ((Bool, [String: Any], String) -> Void)? = nil) {
        let params: [String: String] = ["address": address]
        self.bridge.call(handlerName: "getAccountResources", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }
            guard let temp = response as? [String: Any] else {
                onCompleted?(false, [:], "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let result = temp["result"] as? [String: Any]
            {
                onCompleted?(state, result, "")
            } else {
                onCompleted?(false, [:], "Invalid response format")
            }
        }
    }

    // MARK: createRandom

    public func createRandom(onCompleted: ((Bool, String, String, String, String, String) -> Void)? = nil) {
        let params = [String: String]()
        self.bridge.call(handlerName: "createRandom", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "", "", "", "Invalid response format")
                return
            }

            if let state = temp["state"] as? Bool, state,
               let privateKey = temp["privateKey"] as? String,
               let publicKey = temp["publicKey"] as? String,
               let address = temp["address"] as? String,
               let mnemonic = temp["mnemonic"] as? String
            {
                onCompleted?(state, address, privateKey, publicKey, mnemonic, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", "", "", "", error)
            } else {
                onCompleted?(false, "", "", "", "", "Unknown response format")
            }
        }
    }

    // MARK: createAccount

    public func createAccount(onCompleted: ((Bool, String, String, String, String, String) -> Void)? = nil) {
        let params = [String: String]()
        self.bridge.call(handlerName: "createAccount", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "", "", "", "Invalid response format")
                return
            }

            if let state = temp["state"] as? Bool, state,
               let privateKey = temp["privateKey"] as? String,
               let publicKey = temp["publicKey"] as? String,
               let base58Address = temp["base58Address"] as? String,
               let hexAddress = temp["hexAddress"] as? String
            {
                onCompleted?(state, hexAddress, base58Address, privateKey, publicKey, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", "", "", "", error)
            } else {
                onCompleted?(false, "", "", "", "", "Unknown response format")
            }
        }
    }

    public func importAccountFromMnemonic(mnemonic: String, onCompleted: ((Bool, String, String, String, String) -> Void)? = nil) {
        let params: [String: String] = ["mnemonic": mnemonic]

        self.bridge.call(handlerName: "importAccountFromMnemonic", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "", "", "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let privateKey = temp["privateKey"] as? String,
               let publicKey = temp["publicKey"] as? String,
               let address = temp["address"] as? String
            {
                onCompleted?(state, address, privateKey, publicKey, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", "", "", error)
            } else {
                onCompleted?(false, "", "", "", "Unknown response format")
            }
        }
    }

    public func signMessageV2(message: String,privateKey: String, onCompleted: ((Bool, String, String) -> Void)? = nil) {
        let params: [String: String] = ["message": message,"privateKey": privateKey]

        self.bridge.call(handlerName: "signMessageV2", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "","Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let signature = temp["result"] as? String
            {
                onCompleted?(state, signature,"")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else {
                onCompleted?(false, "","Unknown response format")
            }
        }
    }
    
    public func verifyMessageV2(message: String,signature: String, onCompleted: ((Bool, String, String) -> Void)? = nil) {
        let params: [String: String] = ["message": message,"signature": signature]

        self.bridge.call(handlerName: "verifyMessageV2", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let base58Address = temp["base58Address"] as? String
            {
                onCompleted?(state, base58Address,"")
            }else if let error = temp["error"] as? String {
                onCompleted?(false, "", error)
            } else {
                onCompleted?(false,"", "Unknown response format")
            }
        }
    }
    
    public func importAccountFromPrivateKey(privateKey: String, onCompleted: ((Bool, String, String, String) -> Void)? = nil) {
        let params: [String: String] = ["privateKey": privateKey]

        self.bridge.call(handlerName: "importAccountFromPrivateKey", data: params) { response in
            if self.showLog { print("response = \(String(describing: response))") }

            guard let temp = response as? [String: Any] else {
                onCompleted?(false, "", "", "Invalid response format")
                return
            }
            if let state = temp["state"] as? Bool, state,
               let base58 = temp["base58"] as? String,
               let hex = temp["hex"] as? String
            {
                onCompleted?(state, base58, hex, "")
            } else if let error = temp["error"] as? String {
                onCompleted?(false, "", "", error)
            } else {
                onCompleted?(false, "", "", "Unknown response format")
            }
        }
    }
}

extension TronWeb3 {
    private func doubleValue(string: String) -> Double {
        let decima = NSDecimalNumber(string: string.count == 0 ? "0" : string)
        let doubleValue = Double(truncating: decima as NSNumber)
        return doubleValue
    }
}
