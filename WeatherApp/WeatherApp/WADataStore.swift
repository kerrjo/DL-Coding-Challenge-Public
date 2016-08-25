//
//  WADataStore.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/23/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation
import UIKit

protocol WADataStoreDelegate : class {
    
    func dataStore(controller: WADataStore, didReceiveCurrentConditions conditionItems:[String],
        conditionsDict:[String : AnyObject],
        primaryItems:[String],
        primaryDict:[String : AnyObject])
    
    func dataStore(controller: WADataStore, primaryLocationTitle:String)
    func dataStore(controller: WADataStore, updateForIconImage iconName:String)
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]])
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage)
    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]])
    func dataStore(controller: WADataStore, didReceiveHourlyTen hourPeriods:[[[String : AnyObject]]])

}

extension WADataStoreDelegate {
    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]]){}
    func dataStore(controller: WADataStore, didReceiveHourlyTen hourPeriods:[[[String : AnyObject]]]){}

}



class WADataStore: WAWeatherInfoDelegate {

    weak var delegate: WADataStoreDelegate?

    var weatherInfo = WAWeatherInfo()

    private var imagePlaceholder = UIImage(named: "imageplaceholder")!
    private var imageCache: NSCache = NSCache()
    private var pendingImage = [String:String]()
    
    init(){
        weatherInfo.delegate = self
    }
    
    // MARK: Public API
    
    func getCurrentConditions() {
        weatherInfo.getCurrentConditions()
    }
    
    func getForecast() {
        weatherInfo.getForecast()
    }
    
    func getForecastTen() {
        weatherInfo.getForecastTen()
    }
    
    func getSatellite() {
        weatherInfo.getSattelite()
    }

    func getHourly() {
        weatherInfo.getHourly()
    }
    func getHourlyTen() {
        weatherInfo.getHourlyTen()
    }

    
    // MARK: - WAWeatherInfoDelegate
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourlyTen hourTenPeriods:[[String : AnyObject]]) {

        var dayPeriods:[[String : AnyObject]]
        var tenDayPeriods:[[[String : AnyObject]]] = []

        var currentYday = ""

        dayPeriods = []

        for hourItem in hourTenPeriods {
            
            if let fcTime = hourItem["FCTTIME"] as? [String:AnyObject],
                let yday = fcTime["yday"] as? String {
                if currentYday.isEmpty {
                    currentYday = yday
                }
                if yday == currentYday {
                    dayPeriods += [hourItem]
                } else {
                    
                    tenDayPeriods += [dayPeriods]
                    
//                    print("hourlyItem ...")
//                    for hourlyItem in dayPeriods {
//                        printHourItem(hourlyItem)
//                    }

                    for period in dayPeriods {
                        let icon = period["icon"] as! String
                        let iconURLString = period["icon_url"] as! String
                        self.imageFor(icon, imageURLString: iconURLString)
                    }

                    dayPeriods = []

                    currentYday = yday
                }
            } else {
                tenDayPeriods += [dayPeriods]
            }
        }

    
        delegate?.dataStore(self, didReceiveHourlyTen:tenDayPeriods)
        
    }
    
    
    //        for dayIndex in 0..<10 {
    //            dayPeriods = []
    //
    //            for p in 0..<perPeriod {
    //                let hourItem = hourTenPeriods[dayIndex*perPeriod + p]
    //                dayPeriods += [hourItem]
    //            }
    //
    //            tenDayPeriods += [dayPeriods]
    //
    //            for period in dayPeriods {
    //                let icon = period["icon"] as! String
    //                let iconURLString = period["icon_url"] as! String
    //                self.imageFor(icon, imageURLString: iconURLString)
    //            }
    //
    //
    ////            for hourItem in dayPeriods {
    ////                print(hourItem)
    ////            }
    //            
    //        }
    
    func printHourItem(hourItem:[String:AnyObject]){
        
        var topText = ""
        var bottomText = ""
        //print(period)
        if let fcTime = hourItem["FCTTIME"] {
            if let hour = fcTime["hour"] as? String {
                //print(hour)
                let hourInt:Int? = Int(hour)
                if let intHour = hourInt {
                    if intHour > 12 {
                        bottomText = "\(intHour - 12)"
                    } else {
                        bottomText = "\(intHour)"
                    }
                } else {
                    bottomText = hour
                }
            }
            
            if let ampm = fcTime["ampm"] as? String {
                bottomText += " \(ampm)"
            }
            if let dow = fcTime["weekday_name_abbrev"] as? String {
                bottomText += " \(dow)"
            }
            
            //            if let hourText = fcTime["civil"] as? String {
            //                //print(hourText)
            //            }
        }
        
        if let tempDict = hourItem["temp"] as? [String:AnyObject],
            let temp = tempDict["english"] as? String {
            //print(temp)
            topText = temp
        }
        let icon = hourItem["icon"] as! String
        print("\(topText) \(bottomText) \(icon)")

    }
    
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveHourly hourPeriods:[[String : AnyObject]]) {
        
        delegate?.dataStore(self, didReceiveHourly:hourPeriods)
  
        for period in hourPeriods {
            let icon = period["icon"] as! String
            let iconURLString = period["icon_url"] as! String
            self.imageFor(icon, imageURLString: iconURLString)
        }

    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveCurrentConditions conditions:[String : AnyObject]) {
        
        let currentConditionsDict = conditions
        
        let conditionItemsUnsorted = Array(conditions.keys)
        
        let conditionItems = conditionItemsUnsorted.sort{ $0 < $1 }.filter({ (item) -> Bool in
            
            // Remove undesireables
            if item == "icon" || item == "icon_url"
                || item == "estimated"
            {
                return false
            }
            
            if let valueText = currentConditionsDict[item] as? String {
                if valueText == "NA" {
                    return false
                }
            }
            
            // Remove undesireable primary items
            
            if item == "temperature_string" || item == "weather"
                || item == "feelslike_string"
                || item == "station_id"
                || item == "wind_string"
                || item == "dewpoint_string"
                || item == "display_location"
            {
                return false
            }
            
            return true
        })
        
        
        let icon = currentConditionsDict["icon"] as! String
        let iconURLString = currentConditionsDict["icon_url"] as! String
        
        self.imageFor(icon, imageURLString: iconURLString)
        
        if let displayLocationDict = currentConditionsDict["display_location"] as? [String:AnyObject],
            let cityName = displayLocationDict["city"],
            let stateName = displayLocationDict["state_name"],
            let zipCode = displayLocationDict["zip"]
        {
            let displayString = "\(cityName), \(stateName) \(zipCode)"
            delegate?.dataStore(self, primaryLocationTitle:displayString)
        } else {
            delegate?.dataStore(self, primaryLocationTitle:"")
        }
        
        
        var primaryConditionsDict = [String : AnyObject]()
        var primaryItems:[String] = []
        
        primaryItems += ["Temperature"]
        primaryConditionsDict["Temperature"] = currentConditionsDict["temperature_string"] as! String
        primaryItems += ["Feels Like"]
        primaryConditionsDict["Feels Like"] = currentConditionsDict["feelslike_string"] as! String
        primaryItems += ["Wind"]
        primaryConditionsDict["Wind"] = currentConditionsDict["wind_string"] as! String
        primaryItems += ["Dewpoint"]
        primaryConditionsDict["Dewpoint"] = currentConditionsDict["dewpoint_string"] as! String
        
        delegate?.dataStore(self, didReceiveCurrentConditions:conditionItems,
            conditionsDict:conditions,
            primaryItems:primaryItems,
            primaryDict:primaryConditionsDict
        )

        //  displayLocationDict["full"],
        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        let forecastPeriods = dayPeriods.sort({ (item1, item2) -> Bool in
            let v1 = item1["period"] as! Int
            let v2 = item2["period"] as! Int
            return v1 < v2
        })

        delegate?.dataStore(self, didReceiveDayForecast:forecastPeriods)

        for result in forecastPeriods {
            let icon = result["icon"] as! String
            let iconURLString = result["icon_url"] as! String
            
            self.imageFor(icon, imageURLString: iconURLString)
        }
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject]) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage) {
        delegate?.dataStore(self, didReceiveSatteliteImage:image)
    }
    

    
    // MARK:- Image methods
    
    func imageFor(iconName:String) -> UIImage? {
        
        var result: UIImage?
        if let cachedImage = imageCache.objectForKey(iconName) {
            result = cachedImage as? UIImage
        } else {
            result = imagePlaceholder
        }
        return result
    }
    
    func imageFor(iconName:String, imageURLString:String) -> Void {
        
        // The key for the cache must contain a notion of night vs day
        // icon = clear
        // iconURL = clear.gif or nt_clear.gif
        
        if let _ = pendingImage[imageURLString] {
            return
        }
        pendingImage[imageURLString] = iconName
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let imageURL = NSURL(string: imageURLString),
                imageData = NSData(contentsOfURL:imageURL),
                iconImage = UIImage(data: imageData) {
                
                self.pendingImage.removeValueForKey(imageURLString)
                self.imageCache.setObject(iconImage, forKey: imageURLString)
                
                self.delegate?.dataStore(self, updateForIconImage:imageURLString)
            }
        }
    }

}


// Hourly Item
//
//    ["snow": {
//    english = "0.0";
//    metric = 0;
//    }, "windchill": {
//    english = "-9999";
//    metric = "-9999";
//    }, "icon": clear, "mslp": {
//    english = "30.11";
//    metric = 1020;
//    }, "wx": Mostly Sunny, "condition": Clear, "pop": 0, "heatindex": {
//    english = "-9999";
//    metric = "-9999";
//    }, "uvi": 4, "dewpoint": {
//    english = 63;
//    metric = 17;
//    }, "wspd": {
//    english = 13;
//    metric = 21;
//    }, "FCTTIME": {
//    UTCDATE = "";
//    age = "";
//    ampm = AM;
//    civil = "11:00 AM";
//    epoch = 1472050800;
//    hour = 11;
//    "hour_padded" = 11;
//    isdst = 1;
//    mday = 24;
//    "mday_padded" = 24;
//    min = 00;
//    "min_unpadded" = 0;
//    mon = 8;
//    "mon_abbrev" = Aug;
//    "mon_padded" = 08;
//    "month_name" = August;
//    "month_name_abbrev" = Aug;
//    pretty = "11:00 AM EDT on August 24, 2016";
//    sec = 0;
//    tz = "";
//    "weekday_name" = Wednesday;
//    "weekday_name_abbrev" = Wed;
//    "weekday_name_night" = "Wednesday Night";
//    "weekday_name_night_unlang" = "Wednesday Night";
//    "weekday_name_unlang" = Wednesday;
//    yday = 236;
//    year = 2016;
//    }, "feelslike": {
//    english = 78;
//    metric = 26;
//    }, "wdir": {
//    degrees = 188;
//    dir = S;
//    }, "fctcode": 1, "qpf": {
//    english = "0.0";
//    metric = 0;
//    }, "temp": {
//    english = 78;
//    metric = 26;
//    }, "sky": 20, "humidity": 62, "icon_url": http://icons.wxug.com/i/c/k/clear.gif]
//


