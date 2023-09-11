//
//  ForgetAboutTasksTests.swift
//  ForgetAboutTasksTests
//
//  Created by Константин Малков on 06.03.2023.
//

import XCTest
import Firebase
import GoogleSignIn
import RealmSwift
@testable import ForgetAboutTasks

final class ForgetAboutTasksTests: XCTestCase {
    
    var extensions: UIViewController!
    var stringExt: String!
    var schedule: ScheduleViewController!
    var keychain: KeychainManager!
    var userAuth: UserAuthViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        userAuth = UserAuthViewController()
        extensions = UIViewController()
        stringExt = String()
        schedule = ScheduleViewController()
        keychain = KeychainManager()
        
        
    }

    override func tearDownWithError() throws {
        extensions = nil
        stringExt = nil
        schedule = nil
        keychain = nil
        userAuth = nil
        try super.tearDownWithError()
        
    }
    
//    func testUserAuthController() throws {
//        
//        
//    }
    
    func testEmailValidation() throws {
        XCTAssertTrue(stringExt.emailValidation(email: "test@mail.ru"))
        XCTAssertFalse(stringExt.emailValidation(email: "some_mail.ru"))
        XCTAssertFalse(stringExt.emailValidation(email: "test@mail"))
    }
    
    func testValidationURL() throws {
        XCTAssert(stringExt.urlValidation(text: "www.link.com"))
        XCTAssertFalse(stringExt.urlValidation(text: "nike.com"))
    }
    
    func testKeychainManager() throws {
        let user = "someuser"
        let password = "12345678"
        try! keychain.savePassword(password: password, email: user)
        
        let savedValue = try! keychain.getPassword(email: user)
        XCTAssertEqual(password, savedValue)
        
        
    }
    
    
    func testAccessExtensions() throws {
        //notification
        extensions.request(forUser: UNUserNotificationCenter.current()) { success in
            XCTAssertTrue(success)
        }
        extensions.showNotificationAccessStatus { success in
            XCTAssert(success, "access status")
        }
    }

    func testPerformanceExample() throws {
        
        measure {
            let array = Array(0...10_000)
            var counter = 0
            array.forEach {
                counter += $0
            }
        }
    }

}
