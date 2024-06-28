//
//  ContentView.swift
//  AudioRecorderRahulR
//
//  Created by Rahul R on 28/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = RecordingViewModel()

    var body: some View {
        NavigationView {
            RecordingView(viewModel: viewModel)
                .navigationTitle("Audio Recorder")
        }
    }
}
#Preview {
    ContentView()
}
