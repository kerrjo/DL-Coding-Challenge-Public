//
//  WACurrentConditionsTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WACurrentConditionsTableViewController: UITableViewController, WADataStoreDelegate {

    var weatherInfo = WADataStore()
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!

    var optionTitle = ""
    var primaryTitle = ""

    var primaryItems:[String] = []
    var primaryConditionsDict:[String : AnyObject]?
    
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
            self.refreshTable(nil)
        }
    }
    
    func refreshTable(control:AnyObject?) {
        
        if !refreshInProgress {
            if control == nil {
                // Programmatically started
                self.refreshControl?.beginRefreshing()
            }
            
            self.refreshInProgress = true
            self.weatherInfo.getCurrentConditions()
        }
    }
    

    // MARK: - WADataStoreDelegate
    
    func dataStore(controller: WADataStore, didReceiveCurrentConditions
        conditionItems:[String],
        conditionsDict:[String : AnyObject],
        primaryItems:[String],
        primaryDict:[String : AnyObject]
    )
    {
        self.currentConditionsDict = conditionsDict
        self.conditionItems = conditionItems
        self.primaryItems = primaryItems
        self.primaryConditionsDict = primaryDict
        
        primaryTitle = currentConditionsDict?["weather"] as! String
        optionTitle = "Other items"
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }

        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }
    
    
    func dataStore(controller: WADataStore, primaryLocationTitle:String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.locationLabel.text = primaryLocationTitle
        }
    }

    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {

        dispatch_async(dispatch_get_main_queue()) {
            self.headerImageView.image = controller.imageFor(iconName)
        }

    }

    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
    }


    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let conditionItem = primaryItems[indexPath.row]
            cell.textLabel!.text = conditionItem
            
            if let detailText = primaryConditionsDict?[conditionItem] as? String {
                cell.detailTextLabel!.text = detailText
            } else {
                cell.detailTextLabel!.text = nil
            }

            
        } else {
            let conditionItem = conditionItems[indexPath.row]
            cell.textLabel!.text = conditionItem
            
            if let detailText = currentConditionsDict?[conditionItem] as? String {
                cell.detailTextLabel!.text = detailText
            } else {
                if let detailValue = currentConditionsDict?[conditionItem] as? Double {
                    cell.detailTextLabel!.text = "\(detailValue)"
                } else {
                    cell.detailTextLabel!.text = nil
                }
            }
        }
        
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return primaryTitle
        } else {
            return optionTitle
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return primaryItems.count
        } else if section == 1 {
            return conditionItems.count
        }

        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WAConditionCell", forIndexPath: indexPath)

        // Configure the cell...
        return cell
    }
    

}


