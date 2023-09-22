# TronWeb
**TronWeb** is an iOS toolbelt for interaction with the Tron network.

![language](https://img.shields.io/badge/Language-Swift-green)
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/support-SwiftPackageManager-green)](https://www.swift.org/getting-started/#using-the-package-manager)

![](Resource/DemoImage01.png)

For more specific usage, please refer to the [demo](https://github.com/james19870606/TronWeb/tree/main/Demo/TronWebDemo)

### Swift Package Manager
The Swift Package Manager  is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding TronWeb as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```ruby
dependencies: [
    .package(url: "https://github.com/james19870606/TronWeb.git", .upToNextMajor(from: "1.1.3"))
]
```

### Example usage

```swift
import TronWeb3
```

##### Setup TronWeb3
```swift
let tronWeb = TronWeb3()
let privateKey = ""
let TRONApiKey = ""
if tronWeb.isGenerateTronWebInstanceSuccess != true {
    tronWeb.setup(privateKey: privateKey, node: chainType == .main ? TRONMainNet : TRONNileNet) { [weak self] setupResult in
        guard let self = self else { return }
        if setupResult {
        //......
        }
    }
} else {
        //......

}
```
##### Create Random
```swift
tronWeb.createRandom { [weak self] state, address, privateKey, publicKey, mnemonic, error in
    guard let self = self else { return }
    self.createRandomBtn.isEnabled = true
    tipLabel.text = "create finished."
    if state {
        let text =
            "address: " + address + "\n\n" +
            "mnemonic: " + mnemonic + "\n\n" +
            "privateKey: " + privateKey + "\n\n" +
            "publicKey: " + publicKey
        walletDetailTextView.text = text
    } else {
        walletDetailTextView.text = error
    }
}
```
##### Create Account
```swift
tronWeb.createAccount { [weak self] state, base58Address, hexAddress, privateKey, publicKey, error in
    guard let self = self else { return }
    self.createAccountBtn.isEnabled = true
    tipLabel.text = "create finished."
    if state {
        let text =
            "base58Address: " + base58Address + "\n\n" +
            "hexAddress: " + hexAddress + "\n\n" +
            "privateKey: " + privateKey + "\n\n" +
            "publicKey: " + publicKey
        walletDetailTextView.text = text
    } else {
        walletDetailTextView.text = error
    }
}
```

##### Import Account From Mnemonic
```swift
tronWeb.importAccountFromMnemonic (mnemonic: mnemonic){ [weak self] state, address, privateKey, publicKey, error in
    guard let self = self else { return }
    self.importAccountFromMnemonicBtn.isEnabled = true
    tipLabel.text = "import finished."
    if state {
        let text =
            "address: " + address + "\n\n" +
            "privateKey: " + privateKey + "\n\n" +
            "publicKey: " + publicKey
        walletDetailTextView.text = text
    } else {
        walletDetailTextView.text = error
    }
}
```

##### Send TRX
```swift
let remark = ""
let toAddress = ""
let amountText = "1" // This value is 0.000001 
tronWeb.trxTransferWithRemark(remark: remark,
                                      toAddress: toAddress,
                                      amount: amountText){ [weak self] (state, txid,error) in
    guard let self = self else { return }
    print("state = \(state)")
    print("txid = \(txid)")
    if (state) {
        self.hashLabel.text = txid
    } else {
        self.hashLabel.text = error
    }
}
```
##### Send TRC20
```swift
let remark = ""
let toAddress = ""
let amountText = "1" // This value is 0.000001 
let trc20Address = ""
tronWeb.trc20TokenTransfer(toAddress: toAddress,
                           trc20ContractAddress: trc20Address, amount: amountText,
                           remark: remark,
                           feeLimit: "100000000") { [weak self] (state, txid,error) in
    guard let self = self else { return }
    print("state = \(state)")
    print("txid = \(txid)")
    if (state) {
        self.hashLabel.text = txid
    } else {
        self.hashLabel.text = error
    }
}
```

更详细的使用方法,建议参考 [demo](https://github.com/james19870606/TronWeb/tree/main/Demo/TronWebDemo)

## License

TronWeb is released under the MIT license. [See LICENSE](https://github.com/james19870606/TronWeb/blob/master/LICENSE) for details.
