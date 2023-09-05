//
//  ForgetAboutTasksTests.swift
//  ForgetAboutTasksTests
//
//  Created by Константин Малков on 06.03.2023.
//

import XCTest
import RealmSwift
@testable import ForgetAboutTasks

final class ForgetAboutTasksTests: XCTestCase {
    
    var extensions: UIViewController!
    var stringExt: String!
    var schedule: ScheduleViewController!
    
    
    var sut: RegisterAccountViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = RegisterAccountViewController()
        extensions = UIViewController()
        stringExt = String()
        schedule = ScheduleViewController()
        
        
    }

    override func tearDownWithError() throws {
        extensions = nil
        stringExt = nil
        schedule = nil
        try super.tearDownWithError()
        
    }
    
    func testNewPasswordValidation() throws {
        
        XCTAssert(sut.validatePasswordNew("Header1234"))
    }
    
    func testEmailValidation() throws {
        XCTAssertTrue(stringExt.emailValidation(email: "test@mail.ru"))
    }
    
    func testValidationURL() throws {
        XCTAssert(stringExt.urlValidation(text: "www.link.com"))
    }
    
    func testScheduleView() throws {
        
    }
    
    
    
    func testPasswordValidation() throws {
        XCTAssertTrue(stringExt.passValidation(password: "test12"))
    }
    
    
    func testAccessExtensions() throws {
        //notification
        extensions.request(forUser: UNUserNotificationCenter.current()) { success in
            XCTAssert(success)
        }
        extensions.showNotificationAccessStatus { success in
            XCTAssert(success, "access status")
        }
        
        
    }
    
    func testExample() throws {
        
    }

    func testPerformanceExample() throws {
        
        measure {
            extensions.showNotificationAccessStatus { success in
                XCTAssert(success)
            }
        }
    }

}
