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
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveCurrentConditions conditions:[String : AnyObject]) {
        
        currentConditionsDict = conditions
        
        let conditionItemsUnsorted = Array(conditions.keys)
        
        conditionItems = conditionItemsUnsorted.sort{ $0 < $1 }.filter({ (item) -> Bool in
            
            // Remove undesireables
            if item == "icon" || item == "icon_url"
                || item == "estimated"
            {
                return false
            }
            
            if let valueText = self.currentConditionsDict?[item] as? String {
                if valueText == "NA" {
                    return false
                }
            }
            
            // Remove undesireable primary items
            
            if item == "temperature_string" || item == "weather"
                || item == "feelslike_string"
                || item == "station_id"
                || item == "wind_string"
                || item == "dewpoint_string"
                || item == "display_location"
            {
                return false
            }
            
            return true
        })

        optionTitle = "Other items"

        setupPrimaryItems()

        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        
        let icon = currentConditionsDict?["icon"] as! String
        let iconURLString = currentConditionsDict?["icon_url"] as! String
        
        self.imageFor(icon, imageURLString: iconURLString)
        
        
        if let displayLocationDict = currentConditionsDict?["display_location"] as? [String:AnyObject],
            let cityName = displayLocationDict["city"],
            let stateName = displayLocationDict["state_name"],
            let zipCode = displayLocationDict["zip"]
        {
            let displayString = "\(cityName), \(stateName) \(zipCode)"
            dispatch_async(dispatch_get_main_queue()) {
                self.locationLabel.text = displayString
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.locationLabel.text = ""
            }
        }
        
        //                let fullName = displayLocationDict["full"],
        
        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }
    
    func setupPrimaryItems() {
        
        primaryTitle = currentConditionsDict?["weather"] as! String
        
        primaryConditionsDict = [String : AnyObject]()
        primaryItems = []
        
        primaryItems += ["Temperature"]
        primaryConditionsDict!["Temperature"] = currentConditionsDict?["temperature_string"] as! String
        primaryItems += ["Feels Like"]
        primaryConditionsDict!["Feels Like"] = currentConditionsDict?["feelslike_string"] as! String
        primaryItems += ["Wind"]
        primaryConditionsDict!["Wind"] = currentConditionsDict?["wind_string"] as! String
        primaryItems += ["Dewpoint"]
        primaryConditionsDict!["Dewpoint"] = currentConditionsDict?["dewpoint_string"] as! String
        
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSattelite imageURLs:[String : AnyObject]) {
        // Empty impl
    }
    
    func WeatherInfo(controller: WAWeatherInfo, didReceiveSatteliteImage image:UIImage) {
        // Empty impl
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
