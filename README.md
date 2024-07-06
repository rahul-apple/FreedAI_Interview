
---

# AudioRecorderRahulR

This project is an audio recording application implemented using Swift and SwiftUI. The app provides users with a simple and intuitive interface to record audio, adhering to specified functional, non-functional, and technical requirements.

## Features

### Functional Requirements
- **Start, Stop, Pause, and Resume Recording**: Users can control the recording process with dedicated buttons.
- **Display Recording Duration**: The app shows the duration of the current recording session.

### Non-functional Requirements
- **Thread Safety**: Ensures robust operation across the application.
- **Background Recording**: Allows recording to continue in the background.
- **Interruption Handling**: Manages interruptions from other applications seamlessly.
- **Crash Resilience**: Pauses and saves recordings appropriately if the app crashes or is terminated unexpectedly.

### Technical Requirements
- **Project Naming**: The project is named `AudioRecorderRahulR`.
- **AVAudioEngine and Session Management**: Utilizes `AVAudioEngine` for recording and pausing.
- **MVVM Architecture**: Implements the Model-View-ViewModel (MVVM) pattern for separation of concerns.
- **Code Quality**: The codebase is clean, efficient, and modular, suitable for production.
- **Error Handling**: Comprehensive error handling is implemented throughout.
- **Development Technologies**: Developed using Swift and SwiftUI.
- **Testing**: Includes unit tests and UI tests, with necessary components mocked for testing purposes.

## Design Choices and Implementation

### User Interface
- **Recording Controls**:
  - **Start/Stop Button**: Toggles between "Start" and "Stop" based on the recording state.
  - **Pause/Resume Button**: Appears only when recording is active.
  - **Recording Duration Display**: Shows the formatted duration of the current recording session.
- **Error Handling**:
  - Displays error messages below the recording controls.
- **Recorded Files List**:
  - Lists recorded audio files with their names.
  - Includes a share button next to each file for sharing using `ShareSheet`.
- **ShareSheet**:
  - Custom implementation to present a `UIActivityViewController` for file sharing.

### Functionality
- **Microphone Permission**:
  - Requests microphone permission when needed and shows an error message if denied.
- **Audio Session Setup**:
  - Configures the audio session to support playback and recording with options like Bluetooth and AirPlay.
  - Handles interruptions (e.g., phone calls) by pausing and resuming recording.
- **State Management**:
  - Manages recording state using `@Published` properties in `RecordingViewModel`.
  - Saves and restores recording state using `UserDefaults`.
- **File Management**:
  - Generates file names based on the current date and stores files in the app's document directory.
  - Loads and displays a list of recorded files sorted by creation date.

### Bonus Steps
- **Interruption Handling**:
  - Pauses and resumes the recording session as needed during audio session interruptions.
- **Automatic State Restoration**:
  - Saves the current recording state upon app termination and restores it when the app is relaunched.
- **Enhanced Permission Request for iOS 15+**:
  - Uses the new `AVAudioApplication.requestRecordPermission()` API for iOS 15 and later.

## Alternative Approaches
- **UI Implementation**:
  - Custom buttons with advanced animations and styles.
  - Dynamic list updating using Combine or other reactive frameworks.
- **Error Handling**:
  - User alerts for errors instead of inline messages.
  - More robust logging framework for error tracking.
- **File Management**:
  - Cloud storage integration for saving and sharing recordings.
  - File compression to save storage space.

## Getting Started

To get a local copy up and running, follow these steps:

### Prerequisites
- Xcode 13.0+
- Swift 5.0+

### Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/AudioRecorderRahulR.git
   ```
2. Open the project in Xcode:
   ```sh
   cd AudioRecorderRahulR
   open AudioRecorderRahulR.xcodeproj
   ```
3. Build and run the project on your preferred simulator or device.

## Contributing

Contributions are welcome! Please fork the repository and create a pull request.

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgements

- [AVFoundation](https://developer.apple.com/av-foundation/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

---

Feel free to modify the content to better suit your needs.
