//
//  ViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WAWeatherInfoDelegate {

    var weatherInfo = WAWeatherInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        weatherInfo.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidAppear(animated: Bool) {
        weatherInfo.getCurrentConditions()
        
    }
    
    func WeatherInfoDidReceiveData(controller: WAWeatherInfo) {
        
        print (controller.currentConditions)
        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject]) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage) {
        // Empty impl
    }





}

