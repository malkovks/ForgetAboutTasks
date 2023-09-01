//
//  KeyChainClass.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.05.2023.
//

import Foundation



class KeychainManager {
    
    
    /// Enums for throwing errors if somethings goes wrong with keychain managing
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case failureSaveOnDuplicate(OSStatus)
        case failureOnWrite(OSStatus)
        case failureOnRead(OSStatus)
    }
    
    /// Saving password in Keychain Manager. If data is duplicates - previous data deletes automatically
    /// - Parameters:
    ///   - password: getting password string type for saving in data format
    ///   - email: email string type for saving in kSecAttrAccount
    static func savePassword(password: String, email: String) throws {
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
    static func getPassword(email: String) -> Data? {
        
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "firebase.google.com",
                                    kSecAttrAccount as String: email,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        let _ = SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }
    
    /// Function for delete all data from keychain 
    static func delete(){
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
