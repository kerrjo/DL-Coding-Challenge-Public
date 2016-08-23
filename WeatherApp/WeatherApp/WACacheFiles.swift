//
//  WACacheFiles.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/23/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation


/**
 An extension to NSURL to formulate fileURLS based on service call path
 */

extension NSURL {
    
    class func cacheFileURLFromURL(sourceURL: NSURL, delimiter:String) -> NSURL? {
        
        var resultFileURL: NSURL?
        var relativePathComponents = [String]()
        
        var indexToDocuments = 0
        if let pathComponents = sourceURL.pathComponents {
            
            for path in pathComponents {
                if path == delimiter {
                    break;
                }
                indexToDocuments += 1
            }
            
            let indexPastDocuments = indexToDocuments + 1
            let lastIndex = pathComponents.count
            
            for index in indexPastDocuments..<lastIndex {
                relativePathComponents += [pathComponents[index]]
            }
        }
        
        resultFileURL = cacheFileURL(relativePathComponents)
        
        return resultFileURL
    }
    
    private class func cacheFileURL(inPath:[String]?) -> NSURL? {
        
        var resultFileURL: NSURL?
        var urlPath: NSURL
        
        if let pathComponents = inPath  {
            if pathComponents.count > 0 {
                // Create the path with first component append remaining components
                urlPath = NSURL(string: pathComponents[0])!
                for index in 1..<pathComponents.count {
                    urlPath = urlPath.URLByAppendingPathComponent(pathComponents[index])
                }
                if let pathString = urlPath.path {
                    resultFileURL = cacheFileURLWithRelativePathName(pathString)
                }
            }
        }
        
        return resultFileURL
    }
    
    private class func cacheFileURLWithRelativePathName(pathName: String) -> NSURL? {
        var resultFileURL: NSURL?
        
        let cacheDirectory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory,inDomains: .UserDomainMask).first!
        if let url = NSURL(string:pathName, relativeToURL:cacheDirectory) {
            resultFileURL = url
        }
        
        return resultFileURL
    }
    
}


// MARK: Class WACacheFiles

class WACacheFiles {
    
    // MARK: public api
    
    func readCacheFile(fileURL : NSURL) -> NSData? {
        
        var isDir: ObjCBool = false
        var result : NSData?
        
        if let path = fileURL.path {
            // If it exists and and is valid (not stale) read and use
            if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) {
                if validFile(fileURL) {
                    result = NSData(contentsOfURL: fileURL)
                }
            }
        }
        return result
    }
    
    func writeCacheFile(fileURL : NSURL, data: NSData) {
        prepareFileWrite(fileURL)
        data.writeToURL(fileURL, atomically: true)
    }
    

    // MARK: Private
    
    private func prepareFileWrite(fileURL : NSURL) {
        
        var isDir: ObjCBool = true
        if let pathURL = fileURL.URLByDeletingLastPathComponent,
            let path = pathURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir) {
                
            } else {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtURL(
                        pathURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func validFile(fileURL: NSURL) -> Bool {
        var result = false
        //var fileSize : UInt64 = 0
        var createDate : NSDate? = nil
        
        if let path = fileURL.path {
            do {
                let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
                
                if let _attr = attr {
                    //fileSize = _attr.fileSize()
                    createDate = _attr.fileCreationDate()!
                }
            } catch {
                print("Error: \(error)")
            }
            
        }
        
        if let creationDate = createDate {
            let timeSince = creationDate.timeIntervalSinceNow
            if (-timeSince > 45) {
                do {
                    print("CacheFile Timedout")
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                } catch {
                    print("Error: \(error)")
                }
            } else {
                // Still valid has not timed out
                result = true
            }
        }
        
        return result
    }
    
 }
