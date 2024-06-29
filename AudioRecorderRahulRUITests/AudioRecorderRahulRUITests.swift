//
//  AudioRecorderRahulRUITests.swift
//  AudioRecorderRahulRUITests
//
//  Created by Rahul R on 28/06/24.
//

import XCTest

final class AudioRecorderRahulRUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testStartPauseRecording() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists)
        
        startButton.tap()
        
        // Wait to allow recording to start
        sleep(5)
        
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.exists)
        
        pauseButton.tap()
        
        // Verify recording is paused
        XCTAssertTrue(app.buttons["Resume"].exists)
    }
    
    func testResumeStopRecording() throws {
        let app = XCUIApplication()
        app.launch()
        
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists)
        
        startButton.tap()
        
        // Wait to allow recording to start
        sleep(5)
        
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.exists)
        
        pauseButton.tap()
        
        // Wait to allow recording to pause
        sleep(5)
        
        let resumeButton = app.buttons["Resume"]
        XCTAssertTrue(resumeButton.exists)
        
        resumeButton.tap()
        
        // Wait to allow recording to resume
        sleep(5)
        
        let stopButton = app.buttons["Stop"]
        XCTAssertTrue(stopButton.exists)
        
        stopButton.tap()
        
        // Add assertions to verify recording has stopped
        XCTAssertTrue(startButton.exists)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
