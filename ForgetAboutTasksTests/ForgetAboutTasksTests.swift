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

    var sut : KeychainManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = KeychainManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
        
    }
    
    func testSaveKeychainManager() throws {
        
    }
    
    func testExample() throws {
        
    }

    func testPerformanceExample() throws {
        
        self.measure {
            
        }
    }

}
