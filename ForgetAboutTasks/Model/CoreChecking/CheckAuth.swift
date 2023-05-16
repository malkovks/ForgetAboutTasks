//
//  CheckAuth.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit
import FirebaseAuth

struct UserModel{
    var userName: String
    var userSecondName: String
    var userImage: UIImage
}

class CheckAuth: UIViewController {
    static let shared = CheckAuth()
    
    func isNotAuth() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isAuthorised")
        
    }
    
    func setupForAuth()  {
        UserDefaults.standard.set(true, forKey: "isAuthorised")
    }
    
    func signOut(){
        UserDefaults.standard.setValue("Set your name", forKey: "userName")
        UserDefaults.standard.setValue("No email", forKey: "userMail")
        UserDefaults.standard.setValue(nil, forKey: "userImage")
        UserDefaults.standard.setValue("", forKey: "userAge")
    }
    
    
    
    func loadData() -> (String,String,String,UIImage) {
        var image = UIImage()
        if let data = UserDefaults.standard.data(forKey: "userImage") {
            let decode = try! PropertyListDecoder().decode(Data.self, from: data)
            image = UIImage(data: decode) ?? UIImage(systemName: "photo.circle")!
        } else {
            alertError()
        }
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Error loading name"
        let mail = UserDefaults.standard.string(forKey: "userMail") ?? "Error loading email"
        let age = UserDefaults.standard.string(forKey: "userAge") ?? "Not indicated"
        return (name,mail,age,image)
    }
    
    func saveData(result: AuthDataResult) {
        guard let currentUser = Auth.auth().currentUser,
              let imageURL = currentUser.photoURL,
              let data = try? Data(contentsOf: imageURL) else { return }
//        guard let imageURL = result.user.photoURL else { alertError(text: "Error getting image", mainTitle: "Error");return}
//        downloadImage(url: imageURL) { data in
            UserDefaults.standard.setValue(data, forKey: "userImage")
//        }
        UserDefaults.standard.setValue(result.user.displayName, forKey: "userName")
        UserDefaults.standard.setValue(result.user.email, forKey: "userMail")
    }
    
    
}
