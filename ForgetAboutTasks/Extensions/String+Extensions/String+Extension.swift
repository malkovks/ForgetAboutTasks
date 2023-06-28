//
//  StringExtension.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 20.04.2023.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
    
    struct EmailValidation {
        private static let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        private static let secondPart = "[A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])"
        private static let emailRegex = firstPart + "@" + secondPart + "[A-Za-z]{2,8}"
        static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    }
    
    struct URLValidation {
        private static let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
    }
    
    func emailValidation(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func isEmailValid() -> Bool {
        return EmailValidation.emailPredicate.evaluate(with: self)
    }
    
    func isURLValid(text: String) -> Bool {
        let value = (text.contains("www.") || text.contains("https://") || text.contains("https://www")) && text.contains(".")
        if value {
            return true
        } else {
            return false
        }
    }
    
    func formatPhoneNumber(phoneNumber: String) -> String? {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleanedPhoneNumber.count == 10 else { return nil}
        let areaCode = cleanedPhoneNumber.prefix(3)
        let prefix = cleanedPhoneNumber.dropFirst(3).prefix(3)
        let suffix = cleanedPhoneNumber.dropFirst(6)
        
        return "\(areaCode) \(prefix) + \(suffix)"
    }

    
    func isPhoneNumberValid(text: String) -> Bool {
        let phoneRegex = "^\\+7\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: text)
    }
    
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
