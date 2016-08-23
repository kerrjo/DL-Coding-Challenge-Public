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

    let cacheFiles = WACacheFiles()

    
    // MARK: -

    func getCurrentConditions () {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/conditions/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
        
        if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
            print("Cached response")
            self.processResponseDataConditions(cacheResponse)
            
        } else {
            print("Server response")
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                // HTTP request assumes NSHTTPURLResponse force cast
                
                let httpResponse = response as! NSHTTPURLResponse
                
                print("HTTP Status Code = \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let jsonResponse = data {
                        self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
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

  
    // MARK: -

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
        
        let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
        
        if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
            print("Cached response")
            self.processResponseDataForecast(cacheResponse)

        } else {
            print("Server response")
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                // HTTP request assumes NSHTTPURLResponse force cast
                
                let httpResponse = response as! NSHTTPURLResponse
                
                print("HTTP Status Code = \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let jsonResponse = data {
                        self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
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
    
    
    // MARK: -

    func getSattelite () {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/satellite/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
        
        if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
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
                        self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
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
    

    // MARK: -
    
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

}

