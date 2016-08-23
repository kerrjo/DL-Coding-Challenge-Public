//
//  WASatteliteViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WASatteliteViewController: UIViewController, WADataStoreDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    private var firstLoad = true
    
    //var weatherInfo = WAWeatherInfo()
    var weatherInfo = WADataStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherInfo.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            weatherInfo.getSatellite()
        }
        
        firstLoad = false
    }

    
    // Mark: WADataStoreDelegate
    
    func dataStore(controller: WADataStore, didReceiveCurrentConditions conditionItems:[String],
                   conditionsDict:[String : AnyObject],
                   primaryItems:[String],
                   primaryDict:[String : AnyObject]
        ){
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, primaryTitle:String) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {
        // EMPTY Impl
    }
    
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
        
        dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = image
        }
    }

}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


//    // MARK: - WAWeatherInfoDelegate
//
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveCurrentConditions conditions:[String : AnyObject]) {
//        // Empty impl
//    }
//
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject]) {
//        // Empty impl
//
////        image_url_ir4
////        image_url_vis
////        image_url
//
//        let imageURLBaseString = imageURLs["image_url_vis"]
//        let imageURLString = "\(imageURLBaseString!)\(controller.apiKey)"
//
//        weatherInfo.getSatteliteImageAtURL(imageURLString)
//    }
//
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.imageView.image = image
//        }
//     }
//
//
//    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
//        // Empty impl
//    }
//

