//
//  LanguageManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 04.07.2023.
//

import UIKit

class LanguageManager {
    static let shared = LanguageManager()
    private init () {}
    
    
    /// Set chosen language by user
    /// - Parameter languageCode: language code
    func setLanguage(languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
    }
    
    
    /// Function for returning language value. Basically used when app is start for checking language status
    /// - Returns: return language key
    func getCurrentLanguage() -> String? {
        return UserDefaults.standard.string(forKey: "AppleLanguages")
    }
}
