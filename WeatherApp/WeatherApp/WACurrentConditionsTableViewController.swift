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


    @IBOutlet weak var headerImageView: UIImageView!
    
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
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue()) {
            self.refreshControl?.beginRefreshing()
        }

        refreshTable(nil)
    }
    
    func refreshTable(control:AnyObject?) {
        if !refreshInProgress {
            refreshInProgress = true
            weatherInfo.getCurrentConditions()
        }
    }
    
    // MARK: - WAWeatherInfoDelegate
    
    func WeatherInfoDidReceiveData(controller: WAWeatherInfo) {
        
        // print (controller.currentConditions)
        
        if let conditions = controller.currentConditions {
            
            let conditionItemsUnsorted = Array(conditions.keys)
            
            conditionItems = conditionItemsUnsorted.sort{ $0 < $1 }
            
            currentConditionsDict = controller.currentConditions
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            
            let icon = currentConditionsDict?["icon"] as! String
            let iconURLString = currentConditionsDict?["icon_url"] as! String
            
            self.imageFor(icon, imageURLString: iconURLString)


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
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WAConditionCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    
    
    
    // MARK: Helper
    
    func imageFor(iconName:String, imageURLString:String) -> Void {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let imageURL = NSURL(string: imageURLString),
                imageData = NSData(contentsOfURL:imageURL),
                iconImage = UIImage(data: imageData) {
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.headerImageView.image = iconImage
                }

                
            }
        }
    }


}
