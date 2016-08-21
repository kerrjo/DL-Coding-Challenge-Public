//
//  WAWeatherInfo.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation


protocol WAWeatherInfoDelegate : class {
    func WeatherInfoDidReceiveData(controller: WAWeatherInfo)
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]])

}


class WAWeatherInfo {
    
    weak var delegate: WAWeatherInfoDelegate?
    
    let apiKey = "1dc7e22fb723f500"

    var currentCity = "Detroit"
    var currentState = "MI"
    
    var currentConditions : [String:AnyObject]?
    
    func getCurrentConditions () {
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/conditions/q/\(currentState)/\(currentCity).json"
        
        if let wiURL = NSURL(string: urlString) {
            
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfiguration)
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    
                    print("HTTP Status Code = \(httpResponse.statusCode)")
                    
                    if let jsonResponse = data {
                        
                        do {
                            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                            
                            //print (responseData)
                            
                            if let currentConditionsDict = responseData["current_observation"] as? [String : AnyObject] {
                                self.currentConditions = currentConditionsDict
                                
                            }
                            
                            self.delegate?.WeatherInfoDidReceiveData(self)
                            
                            //print (self.currentConditions)
                            
                        } catch {
                            return
                        }
                    }
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    
    
    func getForecast () {
        
        let urlString = "http://api.wunderground.com/api/1dc7e22fb723f500/forecast/q/\(currentState)/\(currentCity).json"
        
        if let wiURL = NSURL(string: urlString) {
            
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfiguration)
            let task = session.dataTaskWithURL(wiURL) { data, response, error in
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    
                    print("HTTP Status Code = \(httpResponse.statusCode)")
                    
                    if let jsonResponse = data {
                        
                        do {
                            let responseData = try NSJSONSerialization.JSONObjectWithData(jsonResponse, options:[] ) as! [String : AnyObject]
                            
                            //print (responseData)
                            
                            if let forecastDict = responseData["forecast"] as? [String : AnyObject],
                            txtForecastDict = forecastDict["txt_forecast"] as? [String : AnyObject],
                                forecastPeriods = txtForecastDict["forecastday"] as? [[String : AnyObject]]
                            {

                                self.delegate?.WeatherInfo(self, didReceiveDayForecast:forecastPeriods)
                            }
                            
                            //print (self.currentConditions)
                            
                        } catch {
                            return
                        }
                    }
                }
                
            }
            
            task.resume()
            
        }
        
        
        //    "forecast": {
        //    "txt_forecast": {
        //    "date": "2:00 PM PDT",
        //    "forecastday": [{
        //    "period": 0,
        //    "icon": "partlycloudy",
        //    "icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        //    "title": "Tuesday",
        //    "fcttext": "Partly cloudy in the morning, then clear. High of 68F. Breezy. Winds from the West at 10 to 25 mph.",
        //    "fcttext_metric": "Partly cloudy in the morning, then clear. High of 20C. Windy. Winds from the West at 20 to 35 km/h.",
        //    "pop": "0"
        //    }, {
        //    "period": 1,
        //    "icon": "partlycloudy",
        //    "icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
        //    "title": "Tuesday Night",
        //    "fcttext": "Mostly cloudy. Fog overnight. Low of 50F. Winds from the WSW at 5 to 15 mph.",
        //    "fcttext_metric": "Mostly cloudy. Fog overnight. Low of 10C. Breezy. Winds from the WSW at 10 to 20 km/h.",
        //    "pop": "0"
        //    }, {
        //    "period": 2,
        //    "icon": "partlycloudy
        //
        

        
    }

    
    
}
