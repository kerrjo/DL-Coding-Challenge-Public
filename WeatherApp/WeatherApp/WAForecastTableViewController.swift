//
//  WAForecastTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WAForecastTableViewController: UITableViewController, WAWeatherInfoDelegate {

    var weatherInfo = WAWeatherInfo()
    
    var forecastPeriods:[[String : AnyObject]] = []

    private var imagePlaceholder = UIImage(named: "imageplaceholder")!
    private var imageCache: NSCache = NSCache()
    
    var refreshInProgress = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         weatherInfo.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action:#selector(refreshTable(_:)), forControlEvents:[.ValueChanged])
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.beginRefreshing()
        }

        refreshTable(nil)
    }
    
    func refreshTable(control:AnyObject?) {
        if !refreshInProgress {
            refreshInProgress = true
            weatherInfo.getForecast()
        }
    }

    
    // MARK: - WAWeatherInfoDelegate

    func WeatherInfoDidReceiveData(controller: WAWeatherInfo) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject]) {
        // Empty impl
    }
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {

        forecastPeriods = dayPeriods.sort({ (item1, item2) -> Bool in
            let v1 = item1["period"] as! Int
            let v2 = item2["period"] as! Int
            return v1 < v2
        })

        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }

        for result in forecastPeriods {
            let icon = result["icon"] as! String
            let iconURLString = result["icon_url"] as! String

            self.imageFor(icon, imageURLString: iconURLString)
        }
        
        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }

    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        let forecastPeriod = forecastPeriods[indexPath.row]

        if let titleText = forecastPeriod["title"] as? String {

            cell.textLabel!.text = titleText
        }
        
        if let detailText = forecastPeriod["fcttext"] as? String {
            cell.detailTextLabel!.text = detailText
        }
        
        let icon = forecastPeriod["icon"] as! String

        cell.imageView!.image = self.imageFor(icon)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastPeriods.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WAForecastPeriodCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

   
    // MARK: Helper
    
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let imageURL = NSURL(string: imageURLString),
                imageData = NSData(contentsOfURL:imageURL),
                iconImage = UIImage(data: imageData) {
                
                self.imageCache.setObject(iconImage, forKey: iconName)
                
                self.updateFor(iconName)
            }
        }
    }
    
    func updateFor(iconName:String) -> Void {
        
        if let visible = self.tableView.indexPathsForVisibleRows {
            for indexPath in visible {
                if indexPath.row < self.forecastPeriods.count {
                    
                    let forecastPeriod = forecastPeriods[indexPath.row]
                    let icon = forecastPeriod["icon"] as! String
                    
                    if icon == iconName {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
            }
        }  // let visible
    }


}




