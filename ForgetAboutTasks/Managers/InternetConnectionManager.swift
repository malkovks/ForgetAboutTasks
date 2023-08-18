//
//  InternetConnectionManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 18.08.2023.
//

import SystemConfiguration

public class InternetConnectionManager {
    class func isConnectedToInternet() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouter = withUnsafePointer(to: &zeroAddress, { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        } }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouter, &flags){
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needConnection = flags.contains(.connectionRequired)
        print("is reachable",isReachable)
        print("need connection",needConnection)
        return (isReachable && !needConnection)
    }
}
