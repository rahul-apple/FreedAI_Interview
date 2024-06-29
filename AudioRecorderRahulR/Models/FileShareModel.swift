//
//  FileShareModel.swift
//  AudioRecorderRahulR
//
//  Created by Rahul R on 29/06/24.
//

import Foundation
import UIKit
import LinkPresentation

final class FileShareModel: NSObject, UIActivityItemSource {
    let url: URL
    let data: Data
    let title: String
    
    init(url: URL, title: String) throws {
        // Verify the URL is a valid .wav file
        guard url.pathExtension.lowercased() == Constants.File.fileExtension.replacing(".", with: "") else {
            throw NSError(domain: "FileShareModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid file type. Expected .wav"])
        }
        
        self.url = url
        self.title = title
        
        // Load file data
        do {
            self.data = try Data(contentsOf: url)
        } catch {
            throw NSError(domain: "FileShareModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load file data: \(error.localizedDescription)"])
        }
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        url
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        metadata.originalURL = url
        
        // Example: Setting icon provider (you can customize or omit this)
        metadata.iconProvider = NSItemProvider(contentsOf: url)
        return metadata
    }
}

