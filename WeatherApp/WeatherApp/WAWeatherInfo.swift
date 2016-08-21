//
//  WAWeatherInfo.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation


protocol WAWeatherInfoDelegate : class {
    func WAWeatherInfoDidReceiveData(controller: WAWeatherInfo)
}


class WAWeatherInfo {
    
    weak var delegate: WAWeatherInfoDelegate?
    
    let apiKey = "1dc7e22fb723f500"

    var currentCity = "Detroit"
    var currentState = "MI"
    
    var currentConditions : [String:AnyObject]?
    
    
    func getInfo () {
        
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
                            
                            self.delegate?.WAWeatherInfoDidReceiveData(self)
                            
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
}
