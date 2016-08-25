//
//  WAHourlyCollectionViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/24/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WAHourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
}


private let reuseIdentifier = "WAHourlyCollectionViewCell"

class WAHourlyCollectionViewController: UICollectionViewController,WADataStoreDelegate {

    var weatherInfo = WADataStore()

    var hourlyPeriods:[[String : AnyObject]] = []
    
    var refreshInProgress = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        weatherInfo.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func refresh(){
        refreshInProgress = true
        weatherInfo.getHourly()
    }
    
    
    // MARK: - WADataStoreDelegate
    
    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]]) {
        
        hourlyPeriods = hourPeriods
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView?.reloadData()
        }
        
        refreshInProgress = false
    }
    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {
        
        if let visible = self.collectionView?.indexPathsForVisibleItems() {
            for indexPath in visible {
                if indexPath.row < self.hourlyPeriods.count {
                    
                    let hourItem = hourlyPeriods[indexPath.row]
                    let iconURL = hourItem["icon_url"] as! String
                    if iconURL == iconName {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    }
                }
            }
        }  // let visible
    }

    func dataStore(controller: WADataStore, didReceiveCurrentConditions
        conditionItems:[String],
        conditionsDict:[String : AnyObject],
        primaryItems:[String],
        primaryDict:[String : AnyObject]
        )
    {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, primaryLocationTitle:String) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
                                 willDisplayCell cell: UICollectionViewCell,
                                                 forItemAtIndexPath indexPath: NSIndexPath)
        
    {
        let hourCell = cell as! WAHourlyCollectionViewCell
        
        let hourItem = hourlyPeriods[indexPath.row]
        
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
                bottomText += "\n\(dow)"
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
        let iconURL = hourItem["icon_url"] as! String

        hourCell.topLabel.text = topText
        hourCell.bottomLabel.text = bottomText
        //print(iconURL)
        hourCell.imageView.image = weatherInfo.imageFor(iconURL)
        
    }
    
 
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyPeriods.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WAHourlyCollectionViewCell
    
        return cell
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


