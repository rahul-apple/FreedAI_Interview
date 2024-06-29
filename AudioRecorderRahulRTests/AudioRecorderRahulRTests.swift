//
//  AudioRecorderRahulRTests.swift
//  AudioRecorderRahulRTests
//
//  Created by Rahul R on 28/06/24.
//

import XCTest
@testable import AudioRecorderRahulR
import AVFoundation

final class RecordingViewModelTests: XCTestCase {
    var viewModel: RecordingViewModel!
    
    override func setUpWithError() throws {
        viewModel = RecordingViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testStartRecording() throws {
        let expectation = self.expectation(description: "Start Recording")
        
        viewModel.requestMicrophonePermission { granted in
            XCTAssertTrue(granted)
            
            self.viewModel.startRecording()
            XCTAssertEqual(self.viewModel.duration, 0)
            
            // Delay the assertion to give time for the asynchronous code to execute
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssertTrue(self.viewModel.isRecording)
                XCTAssertFalse(self.viewModel.isPaused)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPauseAndResumeRecording() throws {
        let expectation = self.expectation(description: "Pause and Resume Recording")
        viewModel.requestMicrophonePermission { granted in
            XCTAssertTrue(granted)
            
            self.viewModel.startRecording()
            
            // Delay the pauseRecording call to ensure the recording has started
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.viewModel.pauseRecording()
                
                XCTAssertTrue(self.viewModel.isPaused)
                XCTAssertTrue(self.viewModel.isRecording)
                
                // Delay the resumeRecording call to ensure the recording has paused
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.viewModel.resumeRecording()
                    
                    // Delay the assertion to give time for the asynchronous code to execute
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        XCTAssertFalse(self.viewModel.isPaused)
                        XCTAssertTrue(self.viewModel.isRecording)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 7, handler: nil)
    }
    
    func testStopRecording() throws {
        let expectation = self.expectation(description: "Stop Recording")
        
        viewModel.requestMicrophonePermission { granted in
            XCTAssertTrue(granted)
            
            self.viewModel.startRecording()
            
            // Delay the stopRecording call to ensure the recording has started
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.viewModel.stopRecording()
                
                XCTAssertFalse(self.viewModel.isRecording)
                XCTAssertFalse(self.viewModel.isPaused)
                XCTAssertEqual(self.viewModel.duration, 0)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testLoadRecordedFiles() throws {
        viewModel.loadRecordedFiles()
        // Assuming there are no recorded files initially
        XCTAssertFalse(viewModel.recordedFiles.isEmpty)
    }
}


