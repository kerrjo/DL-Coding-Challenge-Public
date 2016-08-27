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
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourly hourPeriods:[[String : AnyObject]])
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourlyTen hourTenPeriods:[[String : AnyObject]])
}

extension WAWeatherInfoDelegate {
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourly hourPeriods:[[String : AnyObject]])
    {}
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourlyTen hourTenPeriods:[[String : AnyObject]])
    {}
}


class WAWeatherInfo {
    
    weak var delegate: WAWeatherInfoDelegate?
    
    let apiKey = "1dc7e22fb723f500"

    var currentCity = "Detroit"
    var currentState = "MI"

    let cacheFiles = WACacheFiles()

    
    func serviceURLFor(service:String) -> NSURL? {

        var result: NSURL?
        let urlString = "http://api.wunderground.com/api/\(apiKey)/\(service)/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return nil
        }
        
        result = wiURL
        
        return result
    }
    
    
    func commonSubmit(wiURL:NSURL, onFailure:(() -> Void)?, completion:(data:NSData) -> Void) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            let httpResponse = response as! NSHTTPURLResponse
            print("HTTP Status Code = \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                
                if let jsonResponse = data {
                    completion(data: jsonResponse)
                    
                }
                
            } // 200
            
        } // dataTaskWithURL completion
        
        task.resume()
    }

    
    
    
    // MARK: -

    func getCurrentConditions () {
        
        if let wiURL = serviceURLFor("conditions") {
            
            let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
            
            if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
                self.processResponseDataConditions(cacheResponse)
                
            } else {
                commonSubmit(wiURL, onFailure:nil) { (jsonResponse) in
                    self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
                    self.processResponseDataConditions(jsonResponse)
                }
            }
        }

    }
    
    func processResponseDataConditions (jsonResponse: NSData) {
        print(#function)
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let currentConditionsDict = responseData["current_observation"] as? [String : AnyObject] {
                self.delegate?.WeatherInfo(self, didReceiveCurrentConditions:currentConditionsDict)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
    }

//    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    let task = session.dataTaskWithURL(wiURL) { data, response, error in
//        
//        // HTTP request assumes NSHTTPURLResponse force cast
//        let httpResponse = response as! NSHTTPURLResponse
//        print("HTTP Status Code = \(httpResponse.statusCode)")
//        if httpResponse.statusCode == 200 {
//            
//            if let jsonResponse = data {
//                self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
//                self.processResponseDataConditions(jsonResponse)
//            }
//            
//        } // 200
//        
//    } // dataTaskWithURL completion
//    
//    task.resume()

    
    // MARK: -
    
    func getHourly () {
        
        if let wiURL = serviceURLFor("hourly") {
            
            let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
            if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
                self.processResponseDataHourly(cacheResponse)
                
            } else {
                commonSubmit(wiURL, onFailure:nil) { (jsonResponse) in
                    self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
                    self.processResponseDataHourly(jsonResponse)
                }
            }
        }
    }
    
    func processResponseDataHourly (jsonResponse: NSData) {
        print(#function)
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let hourlyItems = responseData["hourly_forecast"] as? [[String : AnyObject]] {
                self.delegate?.WeatherInfo(self, didReceiveHourly:hourlyItems)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
    }

//    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    let task = session.dataTaskWithURL(wiURL) { data, response, error in
//        
//        // HTTP request assumes NSHTTPURLResponse force cast
//        let httpResponse = response as! NSHTTPURLResponse
//        print("HTTP Status Code = \(httpResponse.statusCode)")
//        if httpResponse.statusCode == 200 {
//            
//            if let jsonResponse = data {
//                self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
//                self.processResponseDataHourly(jsonResponse)
//            }
//            
//        } // 200
//        
//    } // dataTaskWithURL completion
//    
//    task.resume()

    
    // MARK: -
    
    func getHourlyTen () {
        
        if let wiURL = serviceURLFor("hourly10day") {
            
            let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
            if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
                self.processResponseDataHourlyTen(cacheResponse)
                
            } else {
                commonSubmit(wiURL, onFailure:nil) { (jsonResponse) in
                    self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
                    self.processResponseDataHourlyTen(jsonResponse)
                }
            }
        }
        
    }
    
    func processResponseDataHourlyTen (jsonResponse: NSData) {
        print(#function)
        do {
            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
            
            if let hourlyTenItems = responseData["hourly_forecast"] as? [[String : AnyObject]] {
                self.delegate?.WeatherInfo(self, didReceiveHourlyTen:hourlyTenItems)
            }
            
        } catch {
            print("Error processing JSON \(error)")
        }
    }

//    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    let task = session.dataTaskWithURL(wiURL) { data, response, error in
//        
//        // HTTP request assumes NSHTTPURLResponse force cast
//        let httpResponse = response as! NSHTTPURLResponse
//        print("HTTP Status Code = \(httpResponse.statusCode)")
//        if httpResponse.statusCode == 200 {
//            
//            if let jsonResponse = data {
//                self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
//                self.processResponseDataHourlyTen(jsonResponse)
//            }
//            
//        } // 200
//        
//    } // dataTaskWithURL completion
//    
//    task.resume()

    
  
    // MARK: -

    func getForecast () {
        getForecastWith("forecast")
    }

    func getForecastTen () {
        getForecastWith("forecast10day")
    }

    func getForecastWith (service: String) {
        
        if let wiURL = serviceURLFor(service) {
            
            let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
            if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
                self.processResponseDataForecast(cacheResponse)
                
            } else {
                commonSubmit(wiURL, onFailure:nil) { (jsonResponse) in
                    self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
                    self.processResponseDataForecast(jsonResponse)
                }
            }
        }
    }
    
    func processResponseDataForecast (jsonResponse: NSData) {
        print(#function)
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
    

//    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    let task = session.dataTaskWithURL(wiURL) { data, response, error in
//        
//        // HTTP request assumes NSHTTPURLResponse force cast
//        let httpResponse = response as! NSHTTPURLResponse
//        print("HTTP Status Code = \(httpResponse.statusCode)")
//        if httpResponse.statusCode == 200 {
//            
//            if let jsonResponse = data {
//                self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
//                self.processResponseDataForecast(jsonResponse)
//            }
//            
//        } // 200
//    }
//    
//    task.resume()

    // MARK: -

    func getSattelite () {
        
        if let wiURL = serviceURLFor("satellite") {
            
            let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey)
            if let cacheResponse = cacheFiles.readCacheFile(fileURL!) {
                self.processResponseDataSatellite(cacheResponse)
            } else {
                commonSubmit(wiURL, onFailure:nil) { (jsonResponse) in
                    self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
                    self.processResponseDataSatellite(jsonResponse)
                }
            }
        }
        
    }
    
    func processResponseDataSatellite (jsonResponse: NSData) {
        print(#function)
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
    
//    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    let task = session.dataTaskWithURL(wiURL) { data, response, error in
//        
//        // HTTP request assumes NSHTTPURLResponse force cast
//        let httpResponse = response as! NSHTTPURLResponse
//        print("HTTP Status Code = \(httpResponse.statusCode)")
//        if httpResponse.statusCode == 200 {
//            
//            if let jsonResponse = data {
//                self.cacheFiles.writeCacheFile(fileURL!, data: jsonResponse)
//                self.processResponseDataSatellite(jsonResponse)
//            }
//            
//        } // 200
//    }
//    
//    task.resume()


    // MARK: -
    
    func getSatteliteImageAtURL (urlString: String) {
        
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        commonSubmit(wiURL, onFailure:nil) { (imageData) in
            if let satImage = UIImage(data: imageData) {
                self.delegate?.WeatherInfo(self, didReceiveSatteliteImage: satImage)
            }
        }

        
    }

//        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//        let task = session.dataTaskWithURL(wiURL) { data, response, error in
//            
//            if let httpResponse = response as? NSHTTPURLResponse {
//                
//                print("HTTP Status Code = \(httpResponse.statusCode)")
//                if httpResponse.statusCode == 200 {
//                    if let imageData = data,
//                        let satImage = UIImage(data: imageData) {
//                        self.delegate?.WeatherInfo(self, didReceiveSatteliteImage: satImage)
//                    }
//                    
//                } // 200
//            }
//        }
//        
//        task.resume()
        
        
        
}

