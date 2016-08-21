//
//  WACurrentConditionsTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WACurrentConditionsTableViewController: UITableViewController, WAWeatherInfoDelegate {

    var weatherInfo = WAWeatherInfo()

    var conditionItems:[String] = []
    var currentConditionsDict:[String : AnyObject]?
    
    var refreshInProgress = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherInfo.delegate = self
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action:#selector(refreshTable(_:)), forControlEvents:[.ValueChanged])
        

    }

    override func viewDidAppear(animated: Bool) {
        weatherInfo.getCurrentConditions()
        refreshInProgress = true
    }
    
    func refreshTable(control:AnyObject) {
        if !refreshInProgress {
            refreshInProgress = true
            weatherInfo.getCurrentConditions()

        }
    }
    
    // MARK: - WAWeatherInfoDelegate
    
    func WeatherInfoDidReceiveData(controller: WAWeatherInfo) {
        
        // print (controller.currentConditions)
        
        if let conditions = controller.currentConditions {
            conditionItems = Array(conditions.keys)
            currentConditionsDict = controller.currentConditions
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }

        }
        refreshInProgress = false
        self.refreshControl?.endRefreshing()

        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        // Empty impl
    }
    

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView,
                              willDisplayCell cell: UITableViewCell,
                                              forRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let conditionItem = conditionItems[indexPath.row]
        cell.textLabel!.text = conditionItem
        
        if let detailText = currentConditionsDict?[conditionItem] as? String {
            cell.detailTextLabel!.text = detailText
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditionItems.count
        //return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WAConditionCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

}
