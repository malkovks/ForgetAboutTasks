//
//  FaceIDAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 14.07.2023.
//

import UIKit
import LocalAuthentication

extension UIViewController {
    
    func safetyEnterApplicationWithFaceID(textField: UITextField){
        let context = LAContext()
        context.localizedCancelTitle = "Enter Password"
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your Account") { [weak self] success, error in
            if success {
                UserDefaults.standard.setValue(true, forKey: "isUserConfirmPassword")
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self?.dismiss(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    
    
    func checkAuthForFaceID(handler: @escaping (Bool) -> Void){
        let result = UserDefaults.standard.bool(forKey: "isUserConfirmPassword")
        let context = LAContext()
        var error: NSError?
        
        
        
        if result == true {
            handler(result)
        } else {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to Face ID") { success , error in
                    DispatchQueue.main.async {
                        
                        UserDefaults.standard.setValue(success, forKey: "isUserConfirmPassword")
                        handler(success)
                    }
                }
            }
        }
    }
}

