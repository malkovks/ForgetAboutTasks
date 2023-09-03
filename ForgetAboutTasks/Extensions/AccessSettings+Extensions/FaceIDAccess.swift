//
//  FaceIDAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 14.07.2023.
//

import UIKit
import LocalAuthentication

extension UIViewController {
    
    /// Function check status of Face ID after verification with user's biometrics and set true for authentication if user enter to application
    /// - Parameter textField: needed if face id could not get access to user's face
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
    
    
    
    /// check authentication and access to Face ID
    /// - Parameter handler: return status authentication and status access 
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

