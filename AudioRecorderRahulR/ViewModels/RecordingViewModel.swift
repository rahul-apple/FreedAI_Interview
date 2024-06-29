//
//  RecordingViewModel.swift
//  AudioRecorderRahulR
//
//  Created by Rahul R on 28/06/24.
//

import Foundation
import AVFoundation
import SwiftUI

enum RecordingError: Error {
    case audioEngineError(String)
    case fileError(String)
    case sessionError(String)
}

class RecordingViewModel: NSObject,ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?
    @Published var recordedFiles: [URL] = []
    @Published var sharingAudioFile: URL? // Track currently previewing URL
    
    
    
    override init() {
        super.init()
        self.setupAudioSession()
        self.setupNotifications()
        self.loadState()
        self.loadRecordedFiles()
    }
    
    func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay])
            try audioSession.setActive(true)
            
            // Register for audio session interruptions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: audioSession
            )
        } catch {
            handleError(RecordingError.sessionError("Failed to set up audio session: \(error)"))
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    @objc private func handleAppWillTerminate() {
        if isRecording {
            pauseRecording()
            saveState()
        }
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pauseRecording()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                resumeRecording()
            }
        default:
            break
        }
    }
    
    func startRecording() {
        duration = 0
        errorMessage = ""
        let fileName = formattedCurrentDate() + Constants.File.fileExtension
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        print(fileURL.absoluteString)
        DispatchQueue.main.async {
            do {
                let format = self.audioEngine.inputNode.outputFormat(forBus: 0)
                self.audioFile = try AVAudioFile(forWriting: fileURL, settings: format.settings)
                
                self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    do {
                        try self.audioFile?.write(from: buffer)
                    } catch {
                        self.handleError(RecordingError.fileError("Error writing buffer: \(error)"))
                    }
                }
                
                self.audioEngine.prepare()
                try self.audioEngine.start()
                self.isRecording = true
                self.isPaused = false
                self.startTimer()
            } catch {
                self.handleError(RecordingError.audioEngineError("Failed to start recording: \(error)"))
            }
        }
        
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
        isPaused = false
        stopTimer()
        clearState()
        loadRecordedFiles()
    }
    
    func pauseRecording() {
        audioEngine.pause()
        isPaused = true
        stopTimer()
    }
    
    func resumeRecording() {
        do {
            try audioEngine.start()
            isPaused = false
            startTimer()
        } catch {
            handleError(RecordingError.audioEngineError("Failed to resume recording: \(error)"))
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.duration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func handleError(_ error: RecordingError) {
        switch error {
        case .audioEngineError(let message),
                .fileError(let message),
                .sessionError(let message):
            errorMessage = message
            // Log the error (optional)
            print("Error: \(message)")
        }
    }
    
    func saveState() {
        UserDefaults.standard.set(isRecording, forKey: Constants.UserDefaultsKeys.isRecording)
        UserDefaults.standard.set(duration, forKey: Constants.UserDefaultsKeys.duration)
    }
    
    func loadState() {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isRecording) {
            // duration = UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.duration)
            // Optionally, you can resume the recording here if needed
        }
    }
    
    func clearState() {
        duration = 0
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.isRecording)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.duration)
    }
    
    func loadRecordedFiles() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            self.recordedFiles = files.filter { $0.pathExtension == Constants.File.fileExtension.replacingOccurrences(of: ".", with: "") }
                .sorted(by: { (url1, url2) -> Bool in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2
                })
        } catch {
            self.errorMessage = "Error loading files: \(error.localizedDescription)"
        }
    }
    
    func shareFile(_ url: URL) {
        sharingAudioFile = url
    }
    
    private func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMMM-yyyy-HH-mm-ss"
        return dateFormatter.string(from: Date())
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 15.0, *) {
            Task{
                // Request permission to record.
                if await AVAudioApplication.requestRecordPermission() {
                    // The user grants access.
                    completion(true)
                } else {
                    // The user denies access. Present a message that indicates
                    // that they can change their permission settings in the
                    // Privacy & Security section of the Settings app.
                    completion(false)
                }
            }
        } else {
            // Fallback for earlier iOS versions
            let permissionStatus = audioSession.recordPermission
            
            switch permissionStatus {
            case .granted:
                completion(true)
            case .denied:
                completion(false)
            case .undetermined:
                audioSession.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            default:
                completion(false)
            }
        }
    }
    
}


