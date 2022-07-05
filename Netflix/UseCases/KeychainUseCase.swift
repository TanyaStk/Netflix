//
//  KeychainUseCase.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 04.07.2022.
//

import Foundation

class KeychainUseCase {
    
    enum KeychainError: Error {
        case duplicateEntry
        case itemNotFound
        case invalidItemFormat
        case unknown(OSStatus)
    }
    
    private static let service = "Netflix"
    
    static func save(user: User) throws {
        let password = user.password.data(using: .utf8) ?? Data()
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: user.login as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    static func getUser() throws -> User? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData as String: kCFBooleanTrue
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let dict = result as? [String: AnyObject],
              let passwordData = dict[String(kSecValueData)] as? Data,
              let password = String(data: passwordData, encoding: .utf8),
              let login = (dict[String(kSecAttrAccount)] as? String) else {
            throw KeychainError.invalidItemFormat
        }
        
        return User(login: login, password: password)
    }
    
    static func deleteUser() throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}
