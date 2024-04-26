//
//  KeychainHelper.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-09-17.
//

import Foundation

struct KeychainService {
    func get(key: String) -> String? {
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainServiceAttr,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue ?? true
        ]
        
        var item: CFTypeRef?
        var status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        let data = Data(referencing: item as! NSData)
        let stringData = String(data: data, encoding: String.Encoding.utf8)
        return stringData
    }
}
