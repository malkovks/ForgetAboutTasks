//
//  CheckAuth.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit

class CheckAuth {
    static let shared = CheckAuth()
    
    func isNotAuth() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isAuthorised")
        
    }
    
    func setupForAuth()  {
        UserDefaults.standard.set(true, forKey: "isAuthorised")
    }
}
