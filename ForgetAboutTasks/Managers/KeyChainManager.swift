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
        case unknown(OSStatus)
        case failureSaveOnDuplicate(OSStatus)
        case failureOnWrite(OSStatus)
        case failureOnRead(OSStatus)
    }
    
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
    
    static func checkMailPasswordMatching(email: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "firebase.google.com",
                                    kSecAttrAccount as String: email,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
    }
    
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
    
//    static func getKeychainData(email: String,password: Data) -> Data? {
//        let query = [kSecClass as String: kSecClassInternetPassword,
//                    kSecAttrAccount  as String: email,
//                    kSecAttrServer as String: "firebase.google.com",
//                    kSecReturnData: true] as [AnyHashable : Any]
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        guard status == errSecSuccess,
//              let data = item as? Data else {
//            return Data()
//        }
//        return data
//    }
    
    
    
//    static func checkSavedPassword(){
//        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                    kSecAttrServer as String: "firebase.google.com",
//                                    kSecReturnAttributes as String: true,
//                                    kSecReturnData as String: true]
//        var item: CFTypeRef?
//        let status = SecItemCopyMatching(query as CFDictionary, &item)
//        guard status == errSecSuccess else {
//            //ничего не делаем, пользователь скорее всего не сохранил пароль
//            //дальше просто вводит пароль и почту
//            return
//        }
//        if let existingItem = item as? [String:Any],
//           let emailData = existingItem[kSecAttrAccount as String] as? Data,
//           let email = String(data: emailData, encoding: .utf8),
//           let passwordData = existingItem[kSecValueData as String] as? Data,
//           let password = String(data: passwordData, encoding: .utf8) {
//
//        } else {
//
//        }
//    }
    
//    static func saveToPassword(email: String, password: Data, service: String = "") throws {
//        let query: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
//                                   kSecAttrServer as String: "firebase.google.com",
//                                   kSecAttrAccount as String: email,
//                                   kSecAttrService as String: service]
//        SecItemDelete(query as CFDictionary)
//
//        let attributes: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
//                                         kSecAttrServer as String: "firebase.google.com",
//                                         kSecAttrService as String: service,
//                                         kSecAttrAccount as String: email,
//                                         kSecValueData as String: password]
//
//        let status = SecItemAdd(attributes as CFDictionary, nil)
//        guard status == errSecSuccess else {
//            throw KeychainError.unknown(status)
//        }
//    }
    
//    static func save(service: String, account: String, password: Data) throws {
//        let previousQuery: [String:Any] = [kSecClass as String: kSecClassInternetPassword,
//                                   kSecAttrServer as String: "firebase.google.com",
//                                   kSecAttrAccount as String: account,
//                                   kSecAttrService as String: service]
//        SecItemDelete(previousQuery as CFDictionary)
//
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrServer as String: "firebase.google.com",
//            kSecAttrService as String: service,
//            kSecAttrAccount as String: account,
//            kSecValueData as String: password
//        ]
//
//        let status = SecItemAdd(query as CFDictionary, nil)
//        guard status != errSecDuplicateItem else {
//            throw KeychainError.duplicateEntry
//        }
//
//        guard status == errSecSuccess else {
//            throw KeychainError.unknown(status)
//        }
//    }
    
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
    
//    static func get(service: String, account: String) ->  Data? {
//        let query: [String: AnyObject] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service as AnyObject,
//            kSecAttrAccount as String: account as AnyObject,
//            kSecReturnData as String: kCFBooleanTrue as AnyObject,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//
//        var result: AnyObject?
//        let _ = SecItemCopyMatching(query as CFDictionary, &result)
//        return result as? Data
//    }
}
