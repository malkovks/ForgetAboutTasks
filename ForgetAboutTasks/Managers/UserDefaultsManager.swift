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
    
    
    /// Function for setting up authentication of user and setting true
    func setupForAuth()  {
        UserDefaults.standard.set(true, forKey: "isAuthorised")
    }
    
    /// Function which fix the status of signing out and set all system values for default settings
    func signOut(){
        UserDefaults.standard.set(false, forKey: "isAuthorised")
        UserDefaults.standard.setValue(false, forKey: "isAuthorised")
        UserDefaults.standard.setValue("Set your name".localized(), forKey: "userName")
        UserDefaults.standard.setValue("No email".localized(), forKey: "userMail")
        UserDefaults.standard.setValue(nil, forKey: "userImage")
        UserDefaults.standard.setValue(nil, forKey: "userImageURL")
        UserDefaults.standard.setValue("", forKey: "userAge")
        UserDefaults.standard.setValue("Didot", forKey: "fontNameChanging")
        UserDefaults.standard.setValue(16, forKey: "fontSizeChanging")
        UserDefaults.standard.setValue(0.0, forKey: "fontWeightChanging")
        UserDefaults.standard.setValue(true, forKey: "enableAnimation")
        UserDefaults.standard.setValue(true, forKey: "enableAnimation")
        UserDefaults.standard.setValue(false, forKey: "isPasswordCodeEnabled")
    }
    
    
    /// Loading image from userDefaults,convert from data to image
    /// - Returns: return image from UserDefaults or system image
    func loadSettedImage() -> UIImage {
        var image: UIImage?
        if let data = UserDefaults.standard.data(forKey: "userImage") {//
            let decode = try! PropertyListDecoder().decode(Data.self, from: data)
            image = UIImage(data: decode)
        } else {
            alertError(text: "Can't get user's image".localized())
        }
        return image ?? UIImage(systemName: "photo.circle")!
    }

    
    /// Loading name, mail and age of user from UserDefaults
    /// - Returns: return user's Name, Mail, Age
    func loadData() -> (String,String,String) {
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Set your name".localized()
        let mail = UserDefaults.standard.string(forKey: "userMail") ?? "Error loading email".localized()
        let age = UserDefaults.standard.string(forKey: "userAge") ?? "Set your age".localized()//
        return (name,mail,age)
    }
    
    /// Function for register user account, saving basic parameters
    /// - Parameters:
    ///   - result: auth data result is value which getting from Firebase Authentication
    ///   - user: this value gets if user authenticate with google authentication and get access to data from user's google account
    func saveAccountData(result: AuthDataResult? = nil, user:  GIDGoogleUser? = nil) {
        let profile = user?.profile?.imageURL(withDimension: 320)
        if user == nil {
            UserDefaults.standard.setValue(false, forKey: "authWithGoogle")
        } else {
            UserDefaults.standard.setValue(true, forKey: "authWithGoogle")
        }
        UserDefaults.standard.setValue(true, forKey: "isAuthorised")
        UserDefaults.standard.setValue(result?.user.displayName, forKey: "userName")//
        UserDefaults.standard.setValue(result?.user.email, forKey: "userMail")//
        UserDefaults.standard.set(profile, forKey: "userImageURL")
        UserDefaults.standard.setValue(16, forKey: "fontSizeChanging")//
        UserDefaults.standard.setValue("Didot", forKey: "fontNameChanging")//
        UserDefaults.standard.setValue(0.0, forKey: "fontWeightChanging")//
        UserDefaults.standard.setValue(true, forKey: "enableAnimation")//
        UserDefaults.standard.setValue(true, forKey: "enableVibration")//

    }
    
    /// Setup users interface style and change value every time when functions is calling
    /// - Returns: return true if dark mode is turn on and false if light mode
    func checkDarkModeUserDefaults() -> Bool? {
        let userDefaults = UserDefaults.standard
        let windows = UIApplication.shared.windows
        if userDefaults.bool(forKey: "setUserInterfaceStyle"){//
            windows.first?.overrideUserInterfaceStyle = .dark
            return true
        } else {
            windows.first?.overrideUserInterfaceStyle = .light
            return false
        }
    }
}

