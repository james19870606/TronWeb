//
//  Utils.swift
//  TronKit
//
//  Created by Charles on 2022/8/30.
//

import Foundation
func dicValueString(_ dic: [String: Any]) -> String? {
    let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
    let str = String(data:data!, encoding: String.Encoding.utf8)
    return str
}
