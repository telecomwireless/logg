//
//  FileExtension.swift
//  WeatherApp
//
//  Created by wireless on 3/9/17.
//  Copyright © 2017 keerthichandra Nagareddy. All rights reserved.
//

import Foundation
import XCGLogger


// added the logic to auto rotate and delete log files

extension FileDestination {
    
    
class ExtraClass {
        
        
        public enum Rotation {
            case none
            case onlyAtAppStart
            case alsoWhileWriting
            public var description: String {
                switch self {
                case .none:
                    return "None"
                case .onlyAtAppStart:
                    return "onlyAtAppStart"
                case .alsoWhileWriting:
                    return "alsoWhileWriting"
                }
            }
        }

        open var rotation =  Rotation.alsoWhileWriting
        open var rotationFileSizeBytes = 1024 * 1024  // 1M
        open var rotationFilesMax = 1
        open var rotationFileDateFormat = "-yyyy-MM-dd'T'HH:mm"
        open var rotationFileHasSuffix = true
    
    internal var logFileDirectory: String? = nil

    open  func output(logDetails: LogDetails, message: String) {
        
        let outputClosure = {
            var logDetails = logDetails
            var message = message
            
            // Apply filters, if any indicate we should drop the message, we abort before doing the actual logging
            if self.shouldExclude(logDetails: &logDetails, message: &message) {
                return
            }
            
            self.applyFormatters(logDetails: &logDetails, message: &message)
            
            if let encodedData = "\(message)\n".data(using: String.Encoding.utf8) {
                _try({
                    self.logFileHandle?.write(encodedData)
                },
                     catch: { (exception: NSException) in
                        self.owner?._logln("Objective-C Exception occurred: \(exception)", level: .error)
                })
            }
            
            guard self.rotation == .alsoWhileWriting else {return}
            self.rotateFileAuto(cause: .alsoWhileWriting)
        }
        
        if let logQueue = logQueue {
            logQueue.async(execute: outputClosure)
        }
        else {
            outputClosure()
        }
    }

    private func logFilesNewestFirst() -> [String] {
        var sortedFiles = [String]()
        var action = ""
        
        do {
            let fileManager = FileManager.default
            
            // assemble a dictionary of date:file
            var fileDateMap = [NSDate: String]()
            let iter = fileManager.enumerator(atPath: logFileDirectory!)
            while let element = iter?.nextObject() as? String {
                
                let filePath = logFileDirectory! + element
                action = "get attributes of " + filePath
                let fileAttr = try fileManager.attributesOfItem(atPath: filePath)
                let creationDate = fileAttr[FileAttributeKey.creationDate] as! NSDate
                fileDateMap[creationDate] = filePath
            }
            
            // sort the dates in the dictionary, newest first
            let compareDates: (NSDate, NSDate) -> Bool = {
                return $0.compare($1 as Date) == ComparisonResult.orderedDescending
            }
            let sortedDates = Array(fileDateMap.keys).sorted(by: compareDates)
            
            // assemble array of files using sorted dates
            for key in sortedDates {
                sortedFiles.append(fileDateMap[key]!)
            }
            
            return sortedFiles
            
        } catch let error as NSError {
        owner?._logln("Failed to \(action): \(error.localizedDescription)", level: .error)
            return []
        }
    }
    
    
    func rotateFileAuto(cause: Rotation) {  // parameter unnecessary. for clarity only
        let fileManager = FileManager.default
        let path = writeToFileURL!.path
        
        // prepare parts of rotation file name for future use
        if (!rotateAutoCalledBefore) {
            let indexAfterSlash = path.range(of: "/", options: .backwards)!.upperBound
            let fileName = path.substring(from: indexAfterSlash)
            
            logFileBaseName = fileName
            logFileSuffix = ""
            
            // if there is a "." in file name and the file does use suffix
            if let dotRange = fileName.range(of: ".", options: .backwards),
                rotationFileHasSuffix {
                logFileBaseName = fileName.substring(to: dotRange.lowerBound)
                logFileSuffix = fileName.substring(from: dotRange.lowerBound)
            }
            rotateAutoCalledBefore = true
        }
        
        guard !rotationFailedBefore else {return}  // having seen failure before
        guard fileManager.fileExists(atPath: path) else {return}
        var action = ""  // for the catch clause to report error
        do {
            // quit if log file is not large enough yet
            action = "get attributes of " + path
            let fileAttr = try fileManager.attributesOfItem(atPath: path)
            let fileSize = fileAttr[FileAttributeKey.size] as! NSNumber
            guard fileSize.intValue > rotationFileSizeBytes else {return}
            
            // form rotation file name
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = rotationFileDateFormat
            let dateString = formatter.string(from: Date())
            let rotationFilePath = logFileDirectory! + logFileBaseName + dateString + logFileSuffix
            
            // actually rotate
            //  owner?._logln("Auto rotate for \(cause.description) at size \(fileSize.intValue)", level: .info)
            
            let ret = rotateFile(to: rotationFilePath)
            
            guard ret else {return}  // no new file => no need to delete old ones
            // rotation successful.  delete older files
            let allLogFiles = logFilesNewestFirst()
            guard allLogFiles.count > rotationFilesMax + 1 else {return}
            
            for f in allLogFiles.suffix(from: rotationFilesMax + 1) {  // add 1 for main log file
                action = "delete " + f
                try fileManager.removeItem(atPath: f)
                owner?._logln("Delete old log file \(f)", level: .info)
            }
        } catch let error as NSError {
            owner?._logln("Failed to \(action): \(error.localizedDescription)", level: .error)
            return
        }
    }


    func mostRecentLogFiles(numFiles: Int) -> [URL] {
        var URLs = [URL]()
        var counter = 0
        for f in logFilesNewestFirst() {
            URLs.append(URL(fileURLWithPath: f))
            counter += 1
            guard counter < numFiles else {break}
        }
        return URLs
    }
    
    

 }
    
    
    
    
}
