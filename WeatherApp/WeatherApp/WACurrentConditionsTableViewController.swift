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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        weatherInfo.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        weatherInfo.getCurrentConditions()
    }
    
    
    // MARK: - WAWeatherInfoDelegate
    
    func WeatherInfoDidReceiveData(controller: WAWeatherInfo) {
        
        print (controller.currentConditions)
        
        if let conditions = controller.currentConditions {
            conditionItems = Array(conditions.keys)
            currentConditionsDict = controller.currentConditions
            self.tableView.reloadData()
        }
        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
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

        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
