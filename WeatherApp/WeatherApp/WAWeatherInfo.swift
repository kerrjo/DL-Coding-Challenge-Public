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
    func weatherInfo(controller: WAWeatherInfo, didReceiveCurrentConditions conditions:[String : AnyObject])
    
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]])
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]],
//                     forecastDataPeriods:[[String : AnyObject]])
    func weatherInfo(controller: WAWeatherInfo, didReceiveForecast forecast:[String : AnyObject])

    func weatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject])
    func weatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage)
    func weatherInfo(controller: WAWeatherInfo, didReceiveHourly hourPeriods:[[String : AnyObject]])
    func weatherInfo(controller: WAWeatherInfo, didReceiveHourlyTen hourTenPeriods:[[String : AnyObject]])
}

extension WAWeatherInfoDelegate {
    func weatherInfo(controller: WAWeatherInfo, didReceiveHourly hourPeriods:[[String : AnyObject]])
    {}
    func weatherInfo(controller: WAWeatherInfo, didReceiveHourlyTen hourTenPeriods:[[String : AnyObject]])
    {}
    
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]])
//    {}
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]],
//                     forecastDataPeriods:[[String : AnyObject]])
//    {}
    
    func weatherInfo(controller: WAWeatherInfo, didReceiveForecast forecast:[String : AnyObject])
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

//                    let fieldKeys = Array(currentConditionsDict.keys)
//                    print(fieldKeys)

                    self.delegate?.weatherInfo(self, didReceiveCurrentConditions:currentConditionsDict)
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
                    self.delegate?.weatherInfo(self, didReceiveHourly:hourlyItems)
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
                    self.delegate?.weatherInfo(self, didReceiveHourlyTen:hourlyTenItems)
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
                
                if let forecastDict = responseData["forecast"] as? [String : AnyObject] {
                    self.delegate?.weatherInfo(self, didReceiveForecast:forecastDict)
                }
                
            } catch {
                print("Error processing JSON \(error)")
            }
        }
    }

    //                if let forecastDict = responseData["forecast"] as? [String : AnyObject] {
    //                    let fieldKeys = Array(forecastDict.keys)
    //                    print(fieldKeys)
    //                }

    
    //                var txtForecastDayPeriods = [[String : AnyObject]]()
    //                var simpleForecastDayPeriods = [[String : AnyObject]]()
    //
    //                if let forecastDict = responseData["forecast"] as? [String : AnyObject],
    //                    txtForecastDict = forecastDict["txt_forecast"] as? [String : AnyObject],
    //                    forecastPeriods = txtForecastDict["forecastday"] as? [[String : AnyObject]]
    //                {
    //                    print(forecastPeriods.count)
    //
    //                    txtForecastDayPeriods = forecastPeriods
    //
    //                    //self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
    //                }
    //
    //
    //                if let forecastDict = responseData["forecast"] as? [String : AnyObject],
    //                    simpleForecastDict = forecastDict["simpleforecast"] as? [String : AnyObject],
    //                    simpleForecastPeriods = simpleForecastDict["forecastday"] as? [[String : AnyObject]]
    //                {
    //
    //                    print(simpleForecastPeriods.count)
    //                    let simpleForecastPeriod = simpleForecastPeriods[0]
    //
    //                    let fieldKeys = Array(simpleForecastPeriod.keys)
    //                    print(fieldKeys)
    ////                    print(simpleForecastPeriod)
    //
    //
    //                    simpleForecastDayPeriods = simpleForecastPeriods
    //
    //                    //self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
    //                }
    //
    //                self.delegate?.WeatherInfo(self, didReceiveDayForecast:txtForecastDayPeriods,
    //                            forecastDataPeriods:simpleForecastDayPeriods)
    //


    // MARK: -

    func getSattelite () {
        
        serviceRequest("satellite") {
            (jsonResponse) in

            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                
                if let satteliteDict = responseData["satellite"] as? [String : AnyObject],
                    let imageURLBaseString = satteliteDict["image_url_vis"] as? String {
                    
                    let imageURLString = imageURLBaseString + self.apiKey
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
                self.delegate?.weatherInfo(self, didReceiveSatteliteImage: satImage)
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



