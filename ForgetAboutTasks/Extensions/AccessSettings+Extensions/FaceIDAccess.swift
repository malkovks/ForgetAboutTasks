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
        setupHapticMotion(style: .light)
        let context = LAContext()
        context.localizedCancelTitle = "Enter Password".localized()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your Account".localized()) { [weak self] success, error in
            if success {
                UserDefaults.standard.setValue(success, forKey: "isUserConfirmPassword")
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self?.navigationController?.popViewController(animated: isViewAnimated)
                }
            } else {
                DispatchQueue.main.async {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
    
    
    
    func checkAuthForFaceID(handler: @escaping (Bool) -> Void){
        setupHapticMotion(style: .light)
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to Face ID".localized()) { success , error in
                DispatchQueue.main.async {
                    UserDefaults.standard.setValue(success, forKey: "accessToFaceID")
                    handler(success)
                }
            }
        } else {
            handler(false)
        }
    }
}

