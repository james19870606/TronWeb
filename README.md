# TronWeb
**TronWeb** is an iOS toolbelt for interaction with the Tron network.

![language](https://img.shields.io/badge/Language-Swift-green)
[![CocoaPods](https://img.shields.io/badge/support-SwiftPackageManager-green)](https://www.swift.org/getting-started/#using-the-package-manager)

![](Resource/DemoImage01.png)

For more specific usage, please refer to the [demo](https://github.com/james19870606/TronWeb/tree/main/Demo)

###Swift Package Manager
The Swift Package Manager  is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

```ruby
dependencies: [
    .package(url: "https://github.com/james19870606/TronWeb.git", .upToNextMajor(from: "1.2.0"))
]
```
## 1. Usage in Swift Package Manager
```swift
import TronWeb  
```

## 2. Environment Initialization

Before calling any blockchain functionality, you must initialize the `TronWeb` instance. It is recommended to call this in the `viewDidLoad` of your ViewController or within dedicated initialization logic.

```swift
let tronWeb = TronWeb()

// Initialization parameters:
// - privateKey: Initial private key (optional, defaults to "01" for initialization)
// - node: Node address (TRONMainNet or TRONNileNet)
// - apiKey: Trongrid API Key
do {
    try await tronWeb.setupAsync(
        privateKey: "your_private_key", 
        apiKey: "your_api_key",
        node: TRONNileNet // Testnet
    )
    print("TronWeb initialized successfully")
} catch {
    print("Initialization failed: \(error.localizedDescription)")
}
```

---

## 3. Core Functionality Examples

### 3.1 Account Management

#### Generate Random Wallet (including mnemonic)
```swift
// wordCount: 12, 15, 18, 21, 24
// language: "english", "chinese_simplified", etc.
if let wallet = await tronWeb.createRandomAsync(wordCount: 12, language: "english") {
    let mnemonic = wallet["mnemonic"] as? String
    let privateKey = wallet["privateKey"] as? String
    let address = (wallet["address"] as? [String: Any])?["base58"] as? String
    print("Mnemonic: \(mnemonic ?? "")")
}
```

#### Import Mnemonic
```swift
if let wallet = await tronWeb.importAccountFromMnemonicAsync(mnemonic: "your mnemonic phrase...") {
    if let success = wallet["success"] as? Bool, success {
        let address = (wallet["address"] as? [String: Any])?["base58"] as? String
        print("Import successful: \(address ?? "")")
    }
}
```

#### Query TRX Balance
```swift
if let result = await tronWeb.getTRXBalanceAsync(address: "T...") {
    let balance = result["balance"] as? String // Unit is TRX
    print("Balance: \(balance ?? "0") TRX")
}
```

---

### 3.2 Basic Transfer (Single-Sig)

#### TRX Transfer
```swift
let toAddress = "T..."
let amount: Double = 1.5 // 1.5 TRX
let privateKey = "..."

if let result = await tronWeb.trxTransferAsync(toAddress: toAddress, amount: amount, privateKey: privateKey) {
    if let success = result["success"] as? Bool, success {
        let txid = result["txid"] as? String
        print("Transfer successful, TXID: \(txid ?? "")")
    } else {
        let error = result["error"] as? String
        print("Transfer failed: \(error ?? "Unknown error")")
    }
}
```

#### TRC20 Token Transfer
```swift
let contract = "T..." // Token contract address (e.g., USDT)
let toAddress = "T..."
let amount: Double = 100.0 
let privateKey = "..."

if let result = await tronWeb.trc20TransferAsync(contractAddress: contract, toAddress: toAddress, amount: amount, privateKey: privateKey) {
    if let success = result["success"] as? Bool, success {
        let txid = result["txid"] as? String
        print("Token transfer successful, TXID: \(txid ?? "")")
    }
}
```

---

### 3.3 Multi-Signature (Multi-Sig)

#### Upgrade to Multi-Sig Account
Configuring a regular account as multi-sig requires specifying a list of owners and a threshold.
```swift
let ownerAddress = "T..." // Account to be upgraded
let owners = ["T_Addr1", "T_Addr2", "T_Addr3"]
let threshold = 2
let privateKey = "..." // Current account's private key

if let result = await tronWeb.createMultiSigAddressAsync(
    ownerAddress: ownerAddress,
    owners: owners,
    required: threshold,
    privateKey: privateKey
) {
    if let success = result["success"] as? Bool, success {
        print("Multi-sig configured successfully, TXID: \(result["txid"] ?? "")")
    }
}
```

#### Multi-Sig TRX Transfer
```swift
let fromAddress = "T..." // Multi-sig account address
let privateKeys = ["pk1", "pk2"] // List of private keys meeting the threshold
let permissionId = 2 // Active Permission ID

if let result = await tronWeb.multiSigTrxTransferAsync(
    fromAddress: fromAddress,
    toAddress: "T...",
    amount: 10.0,
    privateKeys: privateKeys,
    permissionId: permissionId
) {
    if let success = result["success"] as? Bool, success {
        print("Multi-sig transfer successful")
    }
}
```

#### Multi-Sig TRC20 Transfer
```swift
let contractAddress = "T..." // TRC20 contract address
let fromAddress = "T..."     // Multi-sig account address
let toAddress = "T..."
let amount: Double = 100.0   // Transfer amount
let privateKeys = ["pk1", "pk2"] // List of private keys meeting the threshold
let permissionId = 2         // Active Permission ID

if let result = await tronWeb.multiSigTrc20TransferAsync(
    contractAddress: contractAddress,
    fromAddress: fromAddress,
    toAddress: toAddress,
    amount: amount,
    privateKeys: privateKeys,
    permissionId: permissionId
) {
    if let success = result["success"] as? Bool, success {
        let txid = result["txid"] as? String
        print("Multi-sig token transfer successful, TXID: \(txid ?? "")")
    } else {
        let error = result["error"] as? String
        print("Multi-sig token transfer failed: \(error ?? "")")
    }
}
```

---

### 3.4 Resource Staking (Stake 2.0)

#### Stake TRX to Obtain Resources
```swift
// resourceType: "ENERGY" or "BANDWIDTH"
if let result = await tronWeb.freezeBalanceAsync(amount: 100, resourceType: "ENERGY", privateKey: "...") {
    if let success = result["success"] as? Bool, success {
        print("Stake successful")
    }
}
```

#### Unfreeze Resources
```swift
if let result = await tronWeb.unfreezeBalanceAsync(amount: 100, resourceType: "ENERGY", privateKey: "...") {
    if let success = result["success"] as? Bool, success {
        print("Unfreeze application submitted successfully")
    }
}

---

### 3.5 Fee Estimation

#### Estimate TRX Transfer Fee
```swift
let toAddress = "T..."
let amount: Double = 10.0
let fromAddress = "T..."

if let result = await tronWeb.estimateTrxFeeAsync(toAddress: toAddress, amount: amount, fromAddress: fromAddress) {
    if let success = result["success"] as? Bool, success {
        let feeTrx = result["feeTrx"] as? Double
        print("Estimated fee: \(feeTrx ?? 0) TRX")
    }
}
```

#### Estimate TRC20 Transfer Fee
```swift
let contract = "T..."
let toAddress = "T..."
let amount: Double = 100.0
let fromAddress = "T..."

if let result = await tronWeb.estimateTrc20FeeAsync(contractAddress: contract, toAddress: toAddress, amount: amount, fromAddress: fromAddress) {
    if let success = result["success"] as? Bool, success {
        let feeTrx = result["feeTrx"] as? Double
        print("Estimated fee: \(feeTrx ?? 0) TRX")
    }
}
```

#### Estimate Multi-Sig TRX Transfer Fee
```swift
let fromAddress = "T..."
let toAddress = "T..."
let amount: Double = 10.0
let privateKeysCount = 2 // Number of required signatures
let permissionId = 2

if let result = await tronWeb.estimateMultiSigTrxFeeAsync(
    fromAddress: fromAddress,
    toAddress: toAddress,
    amount: amount,
    privateKeysCount: privateKeysCount,
    permissionId: permissionId
) {
    if let success = result["success"] as? Bool, success {
        let feeTrx = result["feeTrx"] as? Double
        print("Estimated multi-sig TRX fee: \(feeTrx ?? 0) TRX")
    }
}
```

#### Estimate Multi-Sig TRC20 Transfer Fee
```swift
let contractAddress = "T..."
let fromAddress = "T..."
let toAddress = "T..."
let amount: Double = 100.0
let privateKeysCount = 2
let permissionId = 2

if let result = await tronWeb.estimateMultiSigTrc20FeeAsync(
    contractAddress: contractAddress,
    fromAddress: fromAddress,
    toAddress: toAddress,
    amount: amount,
    privateKeysCount: privateKeysCount,
    permissionId: permissionId
) {
    if let success = result["success"] as? Bool, success {
        let feeTrx = result["feeTrx"] as? Double
        print("Estimated multi-sig TRC20 fee: \(feeTrx ?? 0) TRX")
    }
}
```
## License

TronWeb is released under the MIT license. [See LICENSE](https://github.com/james19870606/TronWeb/blob/master/LICENSE) for details .
