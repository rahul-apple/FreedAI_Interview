//
//  ContentView.swift
//  AudioRecorderRahulR
//
//  Created by Rahul R on 28/06/24.
//

import SwiftUI
import AVFoundation

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @State private var timer: Timer?
    @State private var permissionRequested = false
    
    var body: some View {
        VStack {
            Text("Recording Duration: \(formattedDuration)")
                .padding()
            
            HStack {
                Button(action: {
                    if self.viewModel.isRecording {
                        self.viewModel.stopRecording()
                    } else {
                        self.requestMicrophonePermission()
                        //                        self.viewModel.startRecording()
                        //                        self.startTimer()
                    }
                }) {
                    Text(viewModel.isRecording ? "Stop" : "Start")
                        .padding()
                        .foregroundColor(.white)
                        .background(viewModel.isRecording ? Color.red : Color.green)
                        .cornerRadius(8)
                }
                if viewModel.isRecording {
                    Button(action: {
                        if self.viewModel.isPaused {
                            self.viewModel.resumeRecording()
                            self.startTimer()
                        } else {
                            self.viewModel.pauseRecording()
                            self.stopTimer()
                        }
                    }) {
                        Text(self.viewModel.isPaused ? "Resume" : "Pause")
                            .padding()
                            .foregroundColor(.white)
                            .background(viewModel.isPaused ? Color.blue : Color.gray)
                            .cornerRadius(8)
                            .disabled(!viewModel.isRecording || viewModel.isPaused) // Disable when not recording or not paused
                    }
                }
            }
            .padding()
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            Divider()
            
            List(viewModel.recordedFiles, id: \.self) { file in
                HStack {
                    Text(file.lastPathComponent)
                    Spacer()
                    Button(action: {
                        self.viewModel.playAudio(file)
                    }) {
                        Image(systemName: ((viewModel.audioPlayer?.isPlaying ?? false) && viewModel.currentlyPlayingFile == file) ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onDisappear {
            // Stop timer when view disappears
            self.stopTimer()
        }
        .onAppear {
            self.requestMicrophonePermissionIfNeeded()
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(viewModel.duration) / 60
        let seconds = Int(viewModel.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update UI with current duration
            // This ensures that the view reflects the accurate recording duration
            // viewModel.duration is updated by RecordingViewModel
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                // Permission granted, start recording
                self.viewModel.startRecording()
                self.startTimer()
            } else {
                // Permission denied, handle accordingly (e.g., show alert)
                // Optionally, inform the user or handle the denial
            }
        }
    }
    
    private func requestMicrophonePermissionIfNeeded() {
        if !permissionRequested {
            let permissionStatus = AVAudioSession.sharedInstance().recordPermission
            switch permissionStatus {
            case .granted:
                break
            case .denied:
                break
            case .undetermined:
                viewModel.requestMicrophonePermission { granted in
                    if granted {
                        // Permission granted, you can start recording
                    } else {
                        // Permission denied, handle accordingly (e.g., show alert)
                    }
                }
            }
            permissionRequested = true
        }
    }
}
