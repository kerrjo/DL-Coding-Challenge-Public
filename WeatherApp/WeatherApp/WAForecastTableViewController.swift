//
//  WAForecastTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WAForecastTableViewController: UITableViewController, WADataStoreDelegate {

    // var weatherInfo = WAWeatherInfo()
    
    var weatherInfo = WADataStore()

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
            self.refreshTable(nil)
        }
    }
    
    func refreshTable(control:AnyObject?) {
        if !refreshInProgress {
            if control == nil {
                // Programmatically started
                self.refreshControl?.beginRefreshing()
            }
            
            refreshInProgress = true
            weatherInfo.getForecast()
        }
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
    
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        forecastPeriods = dayPeriods
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }

        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
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

        cell.imageView!.image = self.weatherInfo.imageFor(icon)
        
    }
    
    override func tableView(tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? {
        let result = UITableViewHeaderFooterView()
        result.contentView.backgroundColor = UIColor.clearColor()
        return result
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

}



