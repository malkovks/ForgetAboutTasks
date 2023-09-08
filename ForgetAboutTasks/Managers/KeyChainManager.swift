//
//  KeyChainClass.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.05.2023.
//

import Foundation



class KeychainManager {
    
    static let shared = KeychainManager()
    /// Enums for throwing errors if somethings goes wrong with keychain managing
    enum KeychainError: Error {
        case duplicateEntry
        case unknown
        case failureGetPassword
        case noPassword(OSStatus)
        case failureSaveOnDuplicate(OSStatus)
        case failureOnWrite(OSStatus)
        case failureOnRead(OSStatus)
    }
    
    /// Saving password in Keychain Manager. If data is duplicates - previous data deletes automatically
    /// - Parameters:
    ///   - password: getting password string type for saving in data format
    ///   - email: email string type for saving in kSecAttrAccount
    func savePassword(password: String, email: String) throws {
        let doubleQuery: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
                                   kSecAttrServer as String: "firebase.google.com",
                                   kSecAttrAccount as String: email]
        SecItemDelete(doubleQuery as CFDictionary)
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "firebase.google.com",
                                    kSecAttrAccount as String: email,
                                    kSecValueData as String: password.data(using: .utf8) as Any,
                                    kSecReturnPersistentRef as String: true]
        var persistanceRef: CFTypeRef?
        let status = SecItemAdd(query as CFDictionary, &persistanceRef)
        if status != errSecSuccess {
            throw KeychainError.failureOnWrite(status)
        }
    }
    
    /// Returning data value with full information which was saved in keychain
    /// - Parameter email: entered email as key for getting data
    /// - Returns: return data by input value as key
    func getPassword(email: String) throws -> String {
        
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "firebase.google.com",
                                    kSecAttrAccount as String: email,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword(status)
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.failureOnRead(status)
        }
        
        guard let result = result as? Data, !result.isEmpty else {
            throw KeychainError.unknown
        }
        
        guard let password = String(data: result, encoding: String.Encoding.utf8) else {
            throw KeychainError.failureGetPassword
        }
        
        return password
    }
    
    /// Function for delete all data from keychain 
    func delete(){
        let secItems = [kSecClassGenericPassword,
                        kSecClassInternetPassword,
                        kSecAttrServer,
                        kSecAttrService,
                        kSecClassCertificate,
                        kSecClassKey,
                        kSecClassIdentity]
        
        for item in secItems {
            let spec: NSDictionary = [kSecClass:item]
            SecItemDelete(spec)
        }
    }
}
