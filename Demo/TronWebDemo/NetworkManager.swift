//
//  NetworkManager.swift
//  TronWebDemo
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    // Constants for nodes are defined in TronWeb.swift
    // We'll use those here.
    
    var currentNode: String {
        get {
            return UserDefaults.standard.string(forKey: "selected_tron_node") ?? TRONNileNet
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selected_tron_node")
            NotificationCenter.default.post(name: .networkChanged, object: nil)
        }
    }
    
    var isMainnet: Bool {
        return currentNode == TRONMainNet
    }
    
    var networkName: String {
        return isMainnet ? "Mainnet" : "Nile Testnet"
    }
    
    private init() {}
}

extension Notification.Name {
    static let networkChanged = Notification.Name("TronNetworkChanged")
}
