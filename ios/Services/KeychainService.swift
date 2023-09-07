//
//  KeychainHelper.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-09-17.
//

import Foundation

struct KeychainService {
    let accessGroup: String

    init(accessGroup: String) {
        self.accessGroup = accessGroup
    }

    func get(key: String) -> String? {
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecAttrService as String: keychainServiceAttr,
            kSecReturnData as String: kCFBooleanTrue ?? true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        let data = Data(referencing: item as! NSData)
        let stringData = String(data: data, encoding: String.Encoding.utf8)
        return stringData
    }
}

