# TronWeb
**TronWeb** is an iOS toolbelt for interaction with the Tron network.

![language](https://img.shields.io/badge/Language-Swift-green)
[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-FB7DEC.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![CocoaPods](https://img.shields.io/badge/support-SwiftPackageManager-green)](https://www.swift.org/getting-started/#using-the-package-manager)

![](Resource/DemoImage01.png)

For more specific usage, please refer to the [demo](https://github.com/james19870606/TronWeb/tree/main/Demo/TronWebDemo)

### Installation with CocoaPods
Add this to your [podfile](https://guides.cocoapods.org/using/getting-started.html) and run `pod install` to install:

```ruby
pod 'TronWeb', '~> 1.1.8'
```
### Swift Package Manager
The Swift Package Manager  is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding TronWeb as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```ruby
dependencies: [
    .package(url: "https://github.com/james19870606/TronWeb.git", .upToNextMajor(from: "1.1.9"))
]
```

### Example usage in CocoaPods

```swift
import TronWeb   
```

### Example usage in Swift Package Manager

```swift
import TronWeb3   
```

##### Setup TronWeb3
```swift
let tronWeb = TronWeb3()
let privateKey = ""
let TRONApiKey = ""
if tronWeb.isGenerateTronWebInstanceSuccess != true {
    tronWeb.setup(privateKey: privateKey, node: chainType == .main ? TRONMainNet : TRONNileNet) { [weak self] setupResult,error in
        guard let self = self else { return }
        if setupResult {
        //......
        } else { 
          print(error)
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
##### Import Account From PrivateKey
```swift
tronWeb.importAccountFromPrivateKey (privateKey: privateKey){ [weak self] state, base58, hex, error in
    guard let self = self else { return }
    self.importAccountFromPrivateKeyBtn.isEnabled = true
    tipLabel.text = "import finished."
    if state {
        let text =
            "base58: " + base58 + "\n\n" +
            "hex: " + hex
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

##### Estimate Fee when Send TRX
```swift
let toAddress = reviceAddressField.text,
let amountText = amountTextField.text else { return}
let remark = remarkTextView.text ?? ""
tronWeb.estimateTRXTransferFee(toAddress: toAddress, amount: amountText,note: remark){ (state,sendAccountResources,feeDic,error) in
        if state {
        
        } else {
            
        }
 }
```

##### Estimate Fee when Send TRC20
```swift
let toAddress = ""
let amountText = amountTextField.text
let trc20Address = self.trc20AddressTextField.text 
tronWeb.estimateEnergy(url:chainType == .main ? TRONMainNet : TRONNileNet, toAddress: toAddress, trc20ContractAddress: trc20Address, amount: amountText) { (state,feeDic,error) in
        if state {
              /*
                feeDic =     {
                    energyFee = 420;
                    "energy_used" = 4146;
                    feeLimit = "1.74132";
                };
               */
        } else {
            
        }
}
```
##### signMessageV2
```swift
guard let message = ""
let privateKey = ""
tronWeb.signMessageV2 (message: message,privateKey: privateKey){ [weak self] state, signature, error in
    guard let self = self else { return }
    if state {
        signedTextView.text = signature
    } else {
        signedTextView.text = error
    }
}
```
##### verifyMessageV2
```swift
guard let signature = ""
tronWeb.verifyMessageV2(message: "hello world", signature: signature) { [weak self] state, base58Address, error in
    guard let self = self else { return }
    if state {
        verifyTextView.text = base58Address
    } else {
        verifyTextView.text = error
    }
}
```

更详细的使用方法,建议参考 [demo](https://github.com/james19870606/TronWeb/tree/main/Demo/TronWebDemo)

## License

TronWeb is released under the MIT license. [See LICENSE](https://github.com/james19870606/TronWeb/blob/master/LICENSE) for details .
