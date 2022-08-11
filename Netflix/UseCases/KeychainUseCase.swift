//
//  KeychainUseCase.swift
//  Netflix
//
//  Created by Tanya Samastroyenka on 04.07.2022.
//

import Foundation

protocol Keychain {
    func save(user: User) throws
    func getUser() throws -> User?
    func deleteUser() throws
    func update(user: User) throws
}

class KeychainUseCase: Keychain {
    
    enum KeychainError: Error {
        case duplicateEntry
        case itemNotFound
        case invalidItemFormat
        case unknown(OSStatus)
    }
    
    private let service = "Netflix"
    
    func save(user: User) throws {
        
        let convertedUser = try? JSONEncoder().encode(user)
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: user.login as AnyObject,
            kSecValueData as String: convertedUser as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    func getUser() throws -> User? {
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
              let userData = dict[String(kSecValueData)] as? Data,
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            throw KeychainError.invalidItemFormat
        }
        
        return user
    }
    
    func deleteUser() throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    func update(user: User) throws {
        let convertedUser = try? JSONEncoder().encode(user)
        
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: user.login as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: convertedUser as AnyObject
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}
