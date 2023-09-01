//
//  ColorConverters.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 12.04.2023.
//

import UIKit

extension UIColor {
    
    /// Function decode data and return color
    /// - Parameter data: data with color
    /// - Returns: decoded color
    class func color(withData data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
   
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
