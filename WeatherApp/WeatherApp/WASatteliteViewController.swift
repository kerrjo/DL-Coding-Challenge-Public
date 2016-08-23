//
//  WASatteliteViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WASatteliteViewController: UIViewController, WADataStoreDelegate {

    var weatherInfo = WADataStore()

    @IBOutlet weak var imageView: UIImageView!
    
    private var firstLoad = true

    
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
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = image
        }
    }

    func dataStore(controller: WADataStore, didReceiveCurrentConditions conditionItems:[String],
                   conditionsDict:[String : AnyObject],
                   primaryItems:[String],
                   primaryDict:[String : AnyObject]
        ){
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, primaryLocationTitle:String) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        // EMPTY Impl
    }
    
   
}
