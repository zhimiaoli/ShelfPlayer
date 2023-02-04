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
    
    public var documentsURL: URL!
    private var urlSession: URLSession!
    
    public var downloading = [String: Int]()
    
    override private init() {
        super.init()
        
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func startDownload(url: URL, ext: String, duration: Double, itemId: String, episodeId: String?, index: Int) {
        let task = urlSession.downloadTask(with: url)
        PersistenceController.shared.createDownloadTrack(itemId: itemId, episodeId: episodeId, duration: duration, ext: ext, index: index, identifier: task.taskIdentifier)
        
        
        let id = DownloadHelper.getIdentifier(itemId: itemId, episodeId: episodeId)
        if downloading[id] == nil {
            downloading[id] = 0
        }
        
        task.resume()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.ItemDownloadStatusChanged, object: nil)
        }
    }
}

extension DownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didWriteData _: Int64, totalBytesWritten _: Int64, totalBytesExpectedToWrite _: Int64) {
        print("download progress", downloadTask.taskIdentifier, downloadTask.progress.fractionCompleted)
    }
    func urlSession(_: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let (id, index, itemId, episodeid, ext) = PersistenceController.shared.getDownloadTrackByIdentifier(downloadTask.taskIdentifier) else {
            NSLog("unknown download finished", downloadTask.taskIdentifier)
            return
        }
        
        downloading[id]! += 1
        
        let localItem = PersistenceController.shared.getLocalItem(itemId: itemId, episodeId: episodeid)!
        NSLog("download finished \(id) \(index) (\(downloading[id]!)/\(localItem.numFiles))")
        
        if downloading[id]! == localItem.numFiles {
            downloading[id] = nil
            localItem.isDownloaded = true
            try? PersistenceController.shared.container.viewContext.save()
        }
        
        do {
            let directoryURL = documentsURL.appending(path: id)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            let savedURL = directoryURL.appending(path: "file\(index)\(ext)")
            try FileManager.default.moveItem(at: location, to: savedURL)
            
            NSLog("successfully moved file \(index)")
        } catch {
            PersistenceController.shared.setLocalConflict(itemId: itemId, episodeId: episodeid)
        }
        
        PersistenceController.shared.markTrackAsDownloaded(downloadTask.taskIdentifier)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.ItemDownloadStatusChanged, object: nil)
        }
    }
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("download error", String(describing: error))
            
            if let download = PersistenceController.shared.getDownloadTrackByIdentifier(task.taskIdentifier) {
                PersistenceController.shared.setLocalConflict(itemId: download.2, episodeId: download.3)
            }
        }
    }
}

extension DownloadManager {
    public func downloadCover(coverUrl: URL, id: String) {
        let task = URLSession.shared.downloadTask(with: URLRequest(url: coverUrl)) { localURL, response, error in
            do {
                if let localURL = localURL, error == nil {
                    let directoryURL = self.documentsURL.appending(path: id)
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                    
                    let savedURL = directoryURL.appending(path: "cover.png")
                    try FileManager.default.moveItem(at: localURL, to: savedURL)
                }
            } catch {
                NSLog("Failed to download cover")
            }
        }
        task.resume()
    }
}
