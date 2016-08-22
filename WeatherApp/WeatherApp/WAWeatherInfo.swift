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
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/conditions/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            
            let httpResponse = response as! NSHTTPURLResponse
            
            print("HTTP Status Code = \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                
                if let jsonResponse = data {
                    
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
            
        } // dataTaskWithURL completion
        
        task.resume()
        
    }
    
    
    func getForecast () {
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/forecast/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            
            let httpResponse = response as! NSHTTPURLResponse
            
            print("HTTP Status Code = \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                
                if let jsonResponse = data {
                    
                    do {
                        let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                        
                        if let forecastDict = responseData["forecast"] as? [String : AnyObject],
                            txtForecastDict = forecastDict["txt_forecast"] as? [String : AnyObject],
                            forecastPeriods = txtForecastDict["forecastday"] as? [[String : AnyObject]]
                        {
                            self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
                        }
                        
                        //print (self.currentConditions)
                        
                    } catch {
                        print("Error processing JSON \(error)")
                    }
                }
            }
            
        }
        
        task.resume()
        
    }
    
    
    func getForecastTen () {
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/forecast10day/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            
            let httpResponse = response as! NSHTTPURLResponse
            
            print("HTTP Status Code = \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                
                if let jsonResponse = data {
                    
                    do {
                        let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                        
                        if let forecastDict = responseData["forecast"] as? [String : AnyObject],
                            txtForecastDict = forecastDict["txt_forecast"] as? [String : AnyObject],
                            forecastPeriods = txtForecastDict["forecastday"] as? [[String : AnyObject]]
                        {
                            self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
                        }
                        
                        //print (self.currentConditions)
                        
                    } catch {
                        print("Error processing JSON \(error)")
                    }
                }
            }
            
        }
        
        task.resume()
        
    }

    
    
    func getSattelite () {
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/satellite/q/\(currentState)/\(currentCity).json"
        guard let wiURL = NSURL(string: urlString)
            else {
                print("Error Invalid URL \(urlString)")
                return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(wiURL) { data, response, error in
            
            // HTTP request assumes NSHTTPURLResponse force cast
            
            let httpResponse = response as! NSHTTPURLResponse
            
            print("HTTP Status Code = \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                
                if let jsonResponse = data {
                    
                    do {
                        let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                        
                        //print(responseData)
                        
                        if let satteliteDict = responseData["satellite"] as? [String : AnyObject] {
                            
                            // self.delegate?.WeatherInfo(self, didReceiveSattelite: satteliteDict)
                            
                            let imageURLBaseString = satteliteDict["image_url_vis"]
                            let imageURLString = "\(imageURLBaseString!)\(self.apiKey)"
                            self.getSatteliteImageAtURL(imageURLString)
                        }
                        
                    } catch {
                        print("Error processing JSON \(error)")
                    }
                }
            } // 200
            
        }
        
        task.resume()
        
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
                
                if let imageData = data,
                    let satImage = UIImage(data: imageData) {
                    
                    self.delegate?.WeatherInfo(self, didReceiveSatteliteImage: satImage)
                }
            }
            
        }
        
        task.resume()
        
    }

}

