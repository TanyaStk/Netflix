//
//  KeychainUseCase.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 04.07.2022.
//

import Foundation

class KeychainUseCase {
    
    enum KeyChainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    static func save(account: String, password: String) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password.data(using: .utf8) as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeyChainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeyChainError.unknown(status)
        }
        
        print("saved")
    }
    
    static func get(account: String) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Read status: \(status)")
        
        return result as? Data
    }
}
