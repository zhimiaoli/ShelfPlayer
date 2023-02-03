//
//  DownloadManager.swift
//  Books
//
//  Created by Rasmus Krämer on 03.02.23.
//

import Foundation

// https://www.ralfebert.com/ios-examples/networking/urlsession-background-downloads/
class DownloadManager: NSObject, ObservableObject {
    static var shared = DownloadManager()
    
    private var urlSession: URLSession!
    private var documentsURL: URL!

    override private init() {
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    func startDownload(url: URL, ext: String, itemId: String, episodeId: String?, index: Int) {
        let task = urlSession.downloadTask(with: url)
        PersistenceController.shared.createDownload(itemId: itemId, episodeId: episodeId, ext: ext, index: index, identifier: task.taskIdentifier)
        
        task.resume()
    }
}

extension DownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten _: Int64, totalBytesExpectedToWrite _: Int64) {
        print("download progress", downloadTask.taskIdentifier, downloadTask.progress.fractionCompleted)
    }
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let (id, index, itemId, episodeid, ext) = PersistenceController.shared.getDownloadByIdentifier(downloadTask.taskIdentifier) else {
            NSLog("unknown download finished", downloadTask.taskIdentifier)
            return
        }
        
        NSLog("download finished \(id) \(index)")
        
        do {
            let directoryURL = documentsURL.appending(path: id)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            let savedURL = directoryURL.appending(path: "file\(index)\(ext)")
            try FileManager.default.moveItem(at: location, to: savedURL)
            
            NSLog("successfully moved file \(index)")
        } catch {
            PersistenceController.shared.setLocalConflict(itemId: itemId, episodeId: episodeid)
        }
        
        PersistenceController.shared.deleteDownloadByIdentifier(downloadTask.taskIdentifier)
    }
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("download error", String(describing: error))
            
            if let download = PersistenceController.shared.getDownloadByIdentifier(task.taskIdentifier) {
                PersistenceController.shared.setLocalConflict(itemId: download.2, episodeId: download.3)
            }
            
            PersistenceController.shared.deleteDownloadByIdentifier(task.taskIdentifier)
        }
    }
}
