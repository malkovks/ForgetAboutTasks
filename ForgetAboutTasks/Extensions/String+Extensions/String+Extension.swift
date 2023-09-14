//
//  StringExtension.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 20.04.2023.
//

import UIKit

struct EmailValidation {
    private static let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
    private static let secondPart = "[A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])"
    private static let emailRegex = firstPart + "@" + secondPart + "[A-Za-z]{2,8}"
    static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
}

extension String {
    
    /// Function needed for setting up localization of every text value
    /// - Returns: return string in different localization
    func localized() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
    
    /// Function for checking validation of password
    /// - Parameter password: entered password
    /// - Returns: return boolean value status validation
    func passwordValidation(_ password: String) -> Bool {
        let regex = "^(?=.*[AZ])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    

    func passValidation() -> Bool {
        let regex = "^(?=.*[A-Z])(?=.*[0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    
    /// Check email validation on correct input of email
    /// - Parameter email: inputed email
    /// - Returns: return boolean value status validation
    func emailValidation(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    /// Check URL on correct input
    /// - Parameter text: url input
    /// - Returns: return boolean value
    func urlValidation(text: String) -> Bool {
        let value = (text.contains("www.") || text.contains("https://") || text.contains("https://www")) && text.contains(".")
        if value {
            return true
        } else {
            return false
        }
    }

    
    /// Formating input phone number
    /// - Parameters:
    ///   - mask: format of output phone number like "+X (XXX) XXX-XXXX"
    ///   - phone: phone number in string literal
    /// - Returns: return formatted string
    public static func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "",options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        
        for i in mask where index < numbers.endIndex {
            if i == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(i)
            }
        }
        return result
    }
    
    
}
