//
//  ContentView.swift
//  AudioRecorderRahulR
//
//  Created by Rahul R on 28/06/24.
//

import SwiftUI
import AVFoundation
import QuickLook


struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @State private var timer: Timer?
    @State private var permissionRequested = false // to check the microphone permission requested or not
    @State private var isShowingShareOption = false // ShareSheet is shown
    
    
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
                        } else {
                            self.viewModel.pauseRecording()
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
                        self.viewModel.shareFile(file)
                        self.isShowingShareOption = true
                    }) {
                        Image(systemName: "arrowshape.turn.up.forward")
                            .foregroundColor(.blue)
                    }
                }
            }.selectionDisabled()
        }
        .onAppear {
            self.requestMicrophonePermissionIfNeeded()
        }
        .sheet(isPresented: $isShowingShareOption) {
            if let shareURL = self.viewModel.sharingAudioFile {
                ShareSheet(activityItemURL: shareURL, excludedActivityTypes: nil)
            }
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(viewModel.duration) / 60
        let seconds = Int(viewModel.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func requestMicrophonePermission() {
        self.viewModel.requestMicrophonePermission { granted in
            DispatchQueue.main.async {
                if granted {
                    // Permission granted, start recording
                    self.viewModel.startRecording()
                    self.viewModel.errorMessage = ""
                } else {
                    // Permission denied, handle accordingly (e.g., show alert)
                    // Optionally, inform the user or handle the denial
                    self.viewModel.errorMessage = "Permission denied"
                }
            }
        }
    }
    
    private func requestMicrophonePermissionIfNeeded() {
        if !permissionRequested {
            viewModel.requestMicrophonePermission { _ in
                DispatchQueue.main.async {
                    permissionRequested = true
                }
            }
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    let activityItemURL: URL
    let excludedActivityTypes: [UIActivity.ActivityType]? // Optional
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let fileShareModel = try! FileShareModel(url: activityItemURL, title: activityItemURL.lastPathComponent)
        let activityViewController = UIActivityViewController(activityItems: [fileShareModel], applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedActivityTypes
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the view controller
    }
}
