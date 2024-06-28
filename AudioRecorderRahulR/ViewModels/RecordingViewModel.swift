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

class RecordingViewModel: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?
    @Published var recordedFiles: [URL] = []
    @Published var currentlyPlayingFile: URL?

    
    init() {
        setupAudioSession()
        setupNotifications()
        loadState()
        loadRecordedFiles()
    }
    
    func setupAudioSession() {
        do {
            //            let audioSession = AVAudioSession.sharedInstance()
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
    
    @objc private func handleInterruption(notification: Notification) {
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
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        print(fileURL.absoluteString)
        do {
            let format = audioEngine.inputNode.outputFormat(forBus: 0)
            audioFile = try AVAudioFile(forWriting: fileURL, settings: format.settings)
            
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                do {
                    try self.audioFile?.write(from: buffer)
                } catch {
                    self.handleError(RecordingError.fileError("Error writing buffer: \(error)"))
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            isPaused = false
            startTimer()
        } catch {
            handleError(RecordingError.audioEngineError("Failed to start recording: \(error)"))
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
    
    private func saveState() {
        UserDefaults.standard.set(isRecording, forKey: Constants.UserDefaultsKeys.isRecording)
        UserDefaults.standard.set(duration, forKey: Constants.UserDefaultsKeys.duration)
    }
    
    private func loadState() {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isRecording) {
//            duration = UserDefaults.standard.double(forKey: Constants.UserDefaultsKeys.duration)
            // Optionally, you can resume the recording here if needed
        }
    }
    
    private func clearState() {
        duration = 0
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.isRecording)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.duration)
    }
    
    func loadRecordedFiles() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.temporaryDirectory
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
    
    func playAudio(_ url: URL) {
            do {
                // If the same file is already playing, pause it
                if let audioPlayer = audioPlayer, audioPlayer.isPlaying, currentlyPlayingFile == url {
                    audioPlayer.pause()
                    currentlyPlayingFile = nil
                    return
                }
                
                // Check if the file exists at the given URL
                guard FileManager.default.fileExists(atPath: url.path) else {
                    self.errorMessage = "File not found at \(url.path)"
                    return
                }
                
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .moviePlayback)
                try audioSession.setActive(true)
                
                
                // Initialize the AVAudioPlayer with the file URL
                audioPlayer = try AVAudioPlayer(contentsOf: url)
//                audioPlayer?.delegate = self
                DispatchQueue.main.async {
                    // Prepare and play the audio
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.play()
                }
                // Set the currently playing file
                currentlyPlayingFile = url
            } catch {
                // Log any errors encountered during initialization or playback
                self.errorMessage = "Error playing audio: \(error.localizedDescription)"
            }
        }
    private func formattedCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH-mm-ss"
        return dateFormatter.string(from: Date())
    }
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        audioSession.requestRecordPermission { granted in
            completion(granted)
        }
    }
}


