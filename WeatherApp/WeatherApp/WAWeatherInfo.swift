//
//  WAWeatherInfo.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation
import UIKit

protocol WAWeatherInfoDelegate : class {
    func WeatherInfo(controller: WAWeatherInfo, didReceiveCurrentConditions conditions:[String : AnyObject])
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]])
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject])
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage)
}

class WAWeatherInfo {
    
    weak var delegate: WAWeatherInfoDelegate?
    
    let apiKey = "1dc7e22fb723f500"

    var currentCity = "Detroit"
    var currentState = "MI"
    

    func getCurrentConditions () {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/conditions/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let fileURL = cacheFileURLFromURL(wiURL)
        
        if let cacheResponse = readCacheFile(fileURL!) {
            print("Cached response")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.processResponseDataConditions(cacheResponse)
            }
            
        } else {
            print("Server response")
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                // HTTP request assumes NSHTTPURLResponse force cast
                
                let httpResponse = response as! NSHTTPURLResponse
                
                print("HTTP Status Code = \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let jsonResponse = data {
                        self.writeCacheFile(fileURL!, data: jsonResponse)
                        self.processResponseDataConditions(jsonResponse)
                    }
                }
                
            } // dataTaskWithURL completion
            
            task.resume()
        }
    }
    
    func processResponseDataConditions (jsonResponse: NSData) {
        
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let currentConditionsDict = responseData["current_observation"] as? [String : AnyObject] {
                self.delegate?.WeatherInfo(self, didReceiveCurrentConditions:currentConditionsDict)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
    }

  
    func getForecast () {
        getForecastWith("forecast")
    }

    func getForecastTen () {
        getForecastWith("forecast10day")
    }

    func getForecastWith (service: String) {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/\(service)/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let fileURL = cacheFileURLFromURL(wiURL)
        
        if let cacheResponse = readCacheFile(fileURL!) {
            print("Cached response")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.processResponseDataForecast(cacheResponse)
            }

        } else {
            print("Server response")
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                // HTTP request assumes NSHTTPURLResponse force cast
                
                let httpResponse = response as! NSHTTPURLResponse
                
                print("HTTP Status Code = \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let jsonResponse = data {
                        self.writeCacheFile(fileURL!, data: jsonResponse)
                        self.processResponseDataForecast(jsonResponse)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func processResponseDataForecast (jsonResponse: NSData) {
     
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let forecastDict = responseData["forecast"] as? [String : AnyObject],
                txtForecastDict = forecastDict["txt_forecast"] as? [String : AnyObject],
                forecastPeriods = txtForecastDict["forecastday"] as? [[String : AnyObject]]
            {
                self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
  
    }
    
    
    func getSattelite () {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/satellite/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let fileURL = cacheFileURLFromURL(wiURL)
        
        if let cacheResponse = readCacheFile(fileURL!) {
            print("Cached response")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.processResponseDataSatellite(cacheResponse)
            }
            
        } else {
            print("Server response")
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                // HTTP request assumes NSHTTPURLResponse force cast
                
                let httpResponse = response as! NSHTTPURLResponse
                
                print("HTTP Status Code = \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let jsonResponse = data {
                        self.writeCacheFile(fileURL!, data: jsonResponse)
                        self.processResponseDataSatellite(jsonResponse)
                    }
                } // 200
            }
            
            task.resume()
        }
        
    }
    
    func processResponseDataSatellite (jsonResponse: NSData) {
        
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let satteliteDict = responseData["satellite"] as? [String : AnyObject] {
                
                let imageURLBaseString = satteliteDict["image_url_vis"]
                let imageURLString = "\(imageURLBaseString!)\(self.apiKey)"
                self.getSatteliteImageAtURL(imageURLString)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
        
    }

    
    
    func getSatteliteImageAtURL (urlString: String) {
        
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                
                print("HTTP Status Code = \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    if let imageData = data,
                        let satImage = UIImage(data: imageData) {
                        self.delegate?.WeatherInfo(self, didReceiveSatteliteImage: satImage)
                    }

                } // 200
            }
        }
        
        task.resume()
        
    }
    
    
    
    // MARK: Cached file workers
    
    private func cacheFileURLFromURL(sourceURL: NSURL) -> NSURL? {
        
        var resultFileURL: NSURL?
        var relativePathComponents = [String]()
        
        var indexToDocuments = 0
        if let pathComponents = sourceURL.pathComponents {
            
            for path in pathComponents {
                if path == apiKey {
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
    
    //func cacheFileURLWithFileName(fileName: String, inPath:[String]?) -> NSURL? {
    func cacheFileURL(inPath:[String]?) -> NSURL? {
        
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
    
    func cacheFileURLWithRelativePathName(pathName: String) -> NSURL? {
        var resultFileURL: NSURL?
        
        let cacheDirectory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        
        if let url = NSURL(string:pathName, relativeToURL:cacheDirectory) {
            resultFileURL = url
        }
        
        return resultFileURL
    }
    
    private func prepareFileWrite(fileURL : NSURL) {
        
        var isDir: ObjCBool = false
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
                    print("Timedout")
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
    
    private func readCacheFile(fileURL : NSURL) -> NSData? {
        
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
    
    private func writeCacheFile(fileURL : NSURL, data: NSData) {
        prepareFileWrite(fileURL)
        data.writeToURL(fileURL, atomically: true)
    }

}

