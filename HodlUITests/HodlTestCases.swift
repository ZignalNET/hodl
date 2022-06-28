//
//  HodlTestCases.swift
//  HodlUITests
//
//  Created by Emmanuel Adigun on 2022/06/27.
//

import XCTest

class HodlTestCases: XCTestCase {
    private var app: XCUIApplication!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        app = XCUIApplication()
        // Example of passing in launch arguments which can be read in the app
        // by calling CommandLine.arguments.contains("--uitesting")
        // app.launchArguments.append("--uitesting")
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    

    func testMain() throws {
        //print(app.debugDescription)
        sleep(10)
        snapshot("01-mainview")
        app.tables["summaryTableView"].cells.firstMatch.tap()
        snapshot("02-mainview")
    }
    

}
