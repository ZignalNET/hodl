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
        snapshot("01-home")
        app.tables["summaryTableView"].cells.firstMatch.tap()
        snapshot("02-home")
    }
    
    
    //self.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "rightBarButtonItem_Settings"
    func testSettings() throws {
        sleep(10)
        let settingNavBarButton = app.navigationBars.buttons["rightBarButtonItem_Settings"]
        if settingNavBarButton.exists {
            settingNavBarButton.tap()
            snapshot("01-settings")
        }
    }
    
    func testPendingOrders() throws {
        sleep(10)
        let img = app.images["img_pendingOrderView"]
        if img.exists {
            img.tap()
            snapshot("01-pendingorders")
            sleep(3)
            let details = app.otherElements["pendingOrderDetailView"].firstMatch
            if details.exists {
                details.tap()
                sleep(2)
                snapshot("02-pendingorders")
            }
        }
    }
    
    func testCedentials() throws {
        sleep(1)
        snapshot("01-credentials")
        let c = app.tables["settings_exchangeTableView"].cells.allElementsBoundByIndex[2]
        if c.exists {
            c.tap()
            snapshot("02-credentials")
        }
    }
    
    func testPieTap() throws {
        let exchanges = ["Luno","Binance","Valr","Coinbase"]
        sleep(10)
        print(app.debugDescription)
        var i = 0
        for exchange in exchanges {
            let predicate = NSPredicate(format: "label CONTAINS[c] '\(exchange)'")
            let o = app.otherElements.containing(predicate)
            let m = o.element.firstMatch
            if m.exists  {
                m.tap()
                sleep(1)
                snapshot("02-piechart-\(i+1)")
                i += 1
            }
        }
        
    }

}
