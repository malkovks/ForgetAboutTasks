//
//  CheckAuth.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn


class UserDefaultsManager: UIViewController {
    static let shared = UserDefaultsManager()
    
    func isNotAuth() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isAuthorised")  
    }
    
    func setupForAuth()  {
        UserDefaults.standard.set(true, forKey: "isAuthorised")
    }
    
    func signOut(){
        UserDefaults.standard.setValue("Set your name".localized(), forKey: "userName")
        UserDefaults.standard.setValue("No email".localized(), forKey: "userMail")
        UserDefaults.standard.setValue(nil, forKey: "userImage")
        UserDefaults.standard.setValue("", forKey: "userAge")
    }
    
    func loadSettedImage() -> UIImage {
        var image: UIImage?
        if let data = UserDefaults.standard.data(forKey: "userImage") {
            let decode = try! PropertyListDecoder().decode(Data.self, from: data)
            image = UIImage(data: decode)
        } else {
            alertError(text: "Can't get user's image", mainTitle: "Error!".localized())
        }
        return image ?? UIImage(systemName: "photo.circle")!
    }

    
    func loadData() -> (String,String,String) {
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Error loading name".localized()
        let mail = UserDefaults.standard.string(forKey: "userMail") ?? "Error loading email".localized()
        let age = UserDefaults.standard.string(forKey: "userAge") ?? "Not indicated".localized()
        return (name,mail,age)
    }
    
    func saveData(result: AuthDataResult, user:  GIDGoogleUser) {
        let profile = user.profile?.imageURL(withDimension: 320)

        UserDefaults.standard.setValue(result.user.displayName, forKey: "userName")
        UserDefaults.standard.setValue(result.user.email, forKey: "userMail")
        UserDefaults.standard.set(profile, forKey: "userImageURL")
        UserDefaults.standard.setValue(16, forKey: "fontSizeChanging")
        
    }
    
    func checkDarkModeUserDefaults() -> Bool? {
        let userDefaults = UserDefaults.standard
        let windows = UIApplication.shared.windows
        if userDefaults.bool(forKey: "setUserInterfaceStyle"){
            windows.first?.overrideUserInterfaceStyle = .dark
            return true
        } else {
            windows.first?.overrideUserInterfaceStyle = .light
            return false
        }
    }
}

