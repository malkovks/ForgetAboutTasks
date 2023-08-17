//
//  KeyChainClass.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.05.2023.
//

import Foundation


class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknonw(OSStatus)
    }
    
    static func saveToPassword(email: String, password: Data) throws {
        let query: [String:Any] = [kSecClass as String: kSecClassInternetPassword, kSecAttrServer as String: "firebase.google.com",kSecAttrAccount as String: email]
        SecItemDelete(query as CFDictionary)
        
        let attributes: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                         kSecAttrServer as String: "firebase.google.com",
                                         kSecAttrAccount as String: email,
                                         kSecValueData as String: password]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unknonw(status)
        }
    }
    
    static func getKeychainData(email: String,password: Data) -> Data? {
        let query = [kSecClass as String: kSecClassInternetPassword,
                    kSecAttrAccount  as String: email,
                    kSecAttrServer as String: "firebase.google.com",
                    kSecReturnData: true] as [AnyHashable : Any]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data else {
            return Data()
        }
        return data
    }
    
    
    
    static func checkSavedPassword(){
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "firebase.google.com",
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            //ничего не делаем, пользователь скорее всего не сохранил пароль
            //дальше просто вводит пароль и почту
            return
        }
        if let existingItem = item as? [String:Any],
           let emailData = existingItem[kSecAttrAccount as String] as? Data,
           let email = String(data: emailData, encoding: .utf8),
           let passwordData = existingItem[kSecValueData as String] as? Data,
           let password = String(data: passwordData, encoding: .utf8) {
            
        } else {
            
        }
        
        
    }
    
    static func save(service: String, account: String, password: Data) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknonw(status)
        }
    }
    
    static func delete(){
        let secItems = [kSecClassGenericPassword,
                        kSecClassInternetPassword,
                        kSecClassCertificate,
                        kSecClassKey,
                        kSecClassIdentity]
        
        for item in secItems {
            let spec: NSDictionary = [kSecClass:item]
            SecItemDelete(spec)
        }
    }
    
    static func get(service: String, account: String) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let _ = SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }
}
