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
  
    // MARK: - Public API
    // MARK: -

    func getCurrentConditions () {
        
        serviceRequest("conditions") {
            (jsonResponse) in
            
            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                
                if let currentConditionsDict = responseData["current_observation"] as? [String : AnyObject] {
                    self.delegate?.WeatherInfo(self, didReceiveCurrentConditions:currentConditionsDict)
                }
            } catch {
                print("Error processing JSON \(error)")
            }
        }
        
    }
 
    // MARK: -

    func getHourly () {
        
        serviceRequest("hourly") {
            (jsonResponse) in
            
            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                
                if let hourlyItems = responseData["hourly_forecast"] as? [[String : AnyObject]] {
                    self.delegate?.WeatherInfo(self, didReceiveHourly:hourlyItems)
                }
                
            } catch {
                print("Error processing JSON \(error)")
            }
        }
    }
    
    // MARK: -

    func getHourlyTen () {
        
        serviceRequest("hourly10day") {
            (jsonResponse) in

            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                
                if let hourlyTenItems = responseData["hourly_forecast"] as? [[String : AnyObject]] {
                    self.delegate?.WeatherInfo(self, didReceiveHourlyTen:hourlyTenItems)
                }
                
            } catch {
                print("Error processing JSON \(error)")
            }
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
        
        serviceRequest(service) {
            (jsonResponse) in

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
    }

    // MARK: -

    func getSattelite () {
        
        serviceRequest("satellite") {
            (jsonResponse) in

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
    }
    
    // MARK: -
    
    func getSatteliteImageAtURL (urlString: String) {
        
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        commonSubmit(wiURL, cacheResponse:false, failure:nil) { (imageData) in
            if let satImage = UIImage(data: imageData) {
                self.delegate?.WeatherInfo(self, didReceiveSatteliteImage: satImage)
            }
        }
    }
    

    // MARK: - Private
    
    private func commonSubmit(wiURL:NSURL, cacheResponse:Bool, failure:(() -> Void)?, success:(data:NSData) -> Void) {
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            let httpResponse = response as! NSHTTPURLResponse
            print("HTTP Status Code = \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                
                if let responseData = data {
                    if cacheResponse {
                        let fileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: self.apiKey)
                        if let cacheFileURL = fileURL {
                            self.cacheFiles.writeCacheFile(cacheFileURL, data: responseData)
                        }
                    }
                    success(data: responseData)
                }
                
            } // 200
            else {
                if let failureMethod = failure  {
                    failureMethod()
                }
            }
            
        } // dataTaskWithURL completion
        
        task.resume()
    }
    

    private func serviceRequest(service: String, processResponse:((data:NSData) -> Void)? ) {
        
        let urlString = "http://api.wunderground.com/api/\(apiKey)/\(service)/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }

        if let cacheFileURL = NSURL.cacheFileURLFromURL(wiURL, delimiter: apiKey),
            let cacheResponse = cacheFiles.readCacheFile(cacheFileURL) {
            if let responseMethod = processResponse {
                responseMethod(data: cacheResponse)
            }
        } else {
            commonSubmit(wiURL, cacheResponse: true, failure:nil) { (jsonResponse) in
                if let responseMethod = processResponse {
                    responseMethod(data: jsonResponse)
                }
            }
        }
        
    }

    
}



