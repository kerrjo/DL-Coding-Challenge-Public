//
//  WAHomeTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/28/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


class WAForecastDayCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}

class WAHourlyCell: UITableViewCell {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
}

class WAForecastDescriptionCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
}

class WAHomeSecondaryCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

/**
 Protocol to communicate the location back to the delegate
 */

protocol WAHomeTableDelegate : class {
    func homeTable(controller:WAHomeTableViewController, primaryLocationTitle title:String)
}


/**
 Primary home view tableViewController to display current conditions as well as
 forecast and hourly data
 */

class WAHomeTableViewController: UITableViewController, WADataStoreDelegate , WAHourlyCollectionDataDelegate{

    var weatherInfo = WADataStore()

    weak var delegate:WAHomeTableDelegate?
    
    var primaryTitle = ""
    
    var primaryItems:[String] = []
    var primaryConditionsDict:[String : AnyObject]?
    var conditionItems:[String] = []
    var currentConditionsDict:[String : AnyObject]?

    var secondaryItems:[String] = []
    var secondaryConditionsDict:[String : AnyObject]?

    var forecastPeriods:[[String : AnyObject]] = []
    var forecastDaysData:[[String : AnyObject]] = []

    var hourlyCollectionData = WAHourlyCollectionData()

    var refreshConditionsInProgress = false
    var refreshForecastInProgress = false
    var refreshHourlyInProgress = false

    var refreshInProgress = false

    @IBOutlet weak var tableHeaderLowLabel: UILabel!
    @IBOutlet weak var tableHeaderHighLabel: UILabel!
    @IBOutlet weak var tableHeaderPrimaryLabel: UILabel!
    @IBOutlet weak var tableHeaderImageView: UIImageView!
    @IBOutlet weak var tableHeaderTodayLabel: UILabel!
    @IBOutlet weak var tableHeaderTodayKeyLabel: UILabel!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        weatherInfo.delegate = self
        
        hourlyCollectionData.delegate = self
        hourlyCollectionData.includeDOW = true
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action:#selector(refreshTable(_:)), forControlEvents:[.ValueChanged])
        
        tableHeaderHighLabel.text = ""
        tableHeaderLowLabel.text = ""
        tableHeaderPrimaryLabel.text = ""
        tableHeaderTodayLabel.text = ""
        tableHeaderTodayKeyLabel.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue()) {
            self.refreshTable(nil)
        }
    }
    
    
    // MARK: Refresh 
    
    func refreshTable(control:AnyObject?) {
        
        if !refreshInProgress {
            if control == nil {
                // Programmatically started
                self.refreshControl?.beginRefreshing()
            }
            
            refreshConditionsInProgress = true
            refreshForecastInProgress = true
            refreshHourlyInProgress = true
            
            refreshInProgress = true
            
            weatherInfo.getCurrentConditions()
            weatherInfo.getForecastTen()
            weatherInfo.getHourly()
        }
    }

    func checkRefreshFinished() {
        
        if !refreshConditionsInProgress && !refreshForecastInProgress && !refreshHourlyInProgress {
            
            //print("\(#function) finished!")

            refreshInProgress = false
            
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
            self.updateTableHeaderData()
        }
    }

    
    func updateTableHeaderData() {
        
        if forecastDaysData.count > 0 {
            
            // First day data = Today
            
            let forecastDayData = forecastDaysData[0]
            
            if let highData = forecastDayData["high"],
                let tempf = highData["fahrenheit"] as? String {
                tableHeaderHighLabel.text = tempf
            }
            
            if let highData = forecastDayData["low"],
                let tempf = highData["fahrenheit"] as? String {
                tableHeaderLowLabel.text = tempf
            }
            
            if let dateInfo = forecastDayData["date"],
                let dow = dateInfo["weekday"] as? String {
                tableHeaderTodayLabel.text = dow
            }
            
            tableHeaderTodayKeyLabel.hidden = false
        }
        
        if let tempf = currentConditionsDict?["temp_f"] as? Int {
            tableHeaderPrimaryLabel.text = "\(tempf)"
        }
    }
    
    
    // MARK: - WADataStoreDelegate
    
    func dataStore(controller: WADataStore, didReceiveCurrentConditions conditionItems:[String],
                   conditionsDict:[String : AnyObject],
                   primaryItems:[String],
                   primaryDict:[String : AnyObject],
                   secondaryItems:[String],
                   secondaryDict:[String : AnyObject])
    {
        self.currentConditionsDict = conditionsDict
        self.conditionItems = conditionItems
        //self.primaryItems = primaryItems
        self.primaryItems = []
        self.primaryConditionsDict = primaryDict
        self.secondaryItems = secondaryItems
        self.secondaryConditionsDict = secondaryDict

        primaryTitle = currentConditionsDict?["weather"] as! String
        
        refreshConditionsInProgress = false
        checkRefreshFinished()
    }
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]], forecastDataPeriods:[[String : AnyObject]]) {
        
        forecastPeriods = dayPeriods
        forecastDaysData = forecastDataPeriods
        refreshForecastInProgress = false
        checkRefreshFinished()
    }

    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]]) {

        hourlyCollectionData.hourlyPeriods = hourPeriods
        refreshHourlyInProgress = false
        checkRefreshFinished()
    }

    func dataStore(controller: WADataStore, primaryLocationTitle:String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.homeTable(self, primaryLocationTitle: primaryLocationTitle)
        }
    }
    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {
        
        if let iconURL = currentConditionsDict?["icon_url"] as? String {
            if iconURL == iconName {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableHeaderImageView.image = controller.imageFor(iconName)
                }
            }
        }
        
        if !refreshInProgress {
            updateTableForIconImage(iconName)
            updateCollectionForIconImage(iconName)
        }
    }
    
    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
    }
    
    
    // Mark: WAHourlyCollectionDataDelegate
    
    func hourlyCollection(controller:WAHourlyCollectionData, imageForIcon iconName:String) -> UIImage? {
        return self.weatherInfo.imageFor(iconName)
    }

    
    // MARK: - Tableview
    
    func updateTableForIconImage(iconName:String) {
        
        if let visible = self.tableView.indexPathsForVisibleRows {
            
            for indexPath in visible {
                
                // Update section 2 items
                if indexPath.section == 2 && indexPath.row < self.forecastDaysData.count - 1 {
                    
                    let forecastPeriod = forecastDaysData[indexPath.row + 1] // Ignore first one
                    
                    if let iconURL = forecastPeriod["icon_url"] as? String where iconURL == iconName {
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
    
    
    // MARK: - Configure Cells Methods

    func configureDisplayPrimaryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAHomePrimaryCell
        let conditionItem = primaryItems[indexPath.row]
        cell.textLabel!.text = conditionItem
        
        if let detailText = primaryConditionsDict?[conditionItem] as? String {
            cell.detailTextLabel!.text = detailText
        } else {
            cell.detailTextLabel!.text = nil
        }
    }

    func configureDisplayHourlyCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAHourlyCell
        if let hourlyCell = cell as? WAHourlyCell {
            hourlyCell.collectionView?.reloadData()
            if !refreshInProgress {
                hourlyCell.activity.stopAnimating()
            }
        }
    }

    func configureDisplayForecastDayCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAForecastDayCell
        if let dayCell = cell as? WAForecastDayCell where forecastDaysData.count > 0 {
            
            let forecastDayData = forecastDaysData[indexPath.row + 1] // +1 Ignore first one
            
            
            if let highData = forecastDayData["high"],
                let tempf = highData["fahrenheit"] as? String {
                dayCell.highTempLabel.text = tempf
            }
            
            if let highData = forecastDayData["low"],
                let tempf = highData["fahrenheit"] as? String {
                dayCell.lowTempLabel.text = tempf
            }
            
            if let dateInfo = forecastDayData["date"],
                let dow = dateInfo["weekday"] as? String {
                dayCell.dayLabel.text = dow
            }
            
            if let iconURL = forecastDayData["icon_url"] as? String {
                dayCell.iconImageView!.image = self.weatherInfo.imageFor(iconURL)
            }
        }
    }

    func configureDisplayForecastDescriptionCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAForecastDescriptionCell
        if let descriptionCell = cell as? WAForecastDescriptionCell {
            
            var descriptionText = ""
            
            if forecastPeriods.count > 0 {
                
                let forecastPeriodFirstDay = forecastPeriods[0]
                let forecastPeriodFirstNight = forecastPeriods[1]
                
                if let fcText = forecastPeriodFirstDay["fcttext"] as? String {
                    descriptionText += fcText
                }
                
                if let fcText = forecastPeriodFirstNight["fcttext"] as? String {
                    descriptionText += " " + fcText
                }
            }
            
            descriptionCell.descriptionLabel.text = descriptionText
        }
    }

    func configureDisplayHomeSecondaryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAHomeSecondaryCell
        if let secondaryCell = cell as? WAHomeSecondaryCell {
            let conditionItem = secondaryItems[indexPath.row]
            secondaryCell.keyLabel!.text = conditionItem
        
            if let detailText = secondaryConditionsDict?[conditionItem] as? String {
                secondaryCell.valueLabel.text = detailText
            }
        }
    }

    func configureDisplayHomeDataCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //WAHomeDataCell
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

    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            // "WAHomePrimaryCell"
            configureDisplayPrimaryCell(cell, forRowAtIndexPath: indexPath)

        } else if indexPath.section == 1 {
            // "WAHourlyCell"
            configureDisplayHourlyCell(cell, forRowAtIndexPath: indexPath)
            
        } else if indexPath.section == 2 {
            // "WAForecastDayCell"
            configureDisplayForecastDayCell(cell, forRowAtIndexPath: indexPath)
            
        } else if indexPath.section == 3 {
            // "WAForecastDescriptionCell"
            configureDisplayForecastDescriptionCell(cell, forRowAtIndexPath: indexPath)
            
        } else if indexPath.section == 4 {
            // "WAHomeSecondaryCell"
            configureDisplayHomeSecondaryCell(cell, forRowAtIndexPath: indexPath)
            
        } else if indexPath.section == 5 {
            // "WAHomeDataCell"
            configureDisplayHomeDataCell(cell, forRowAtIndexPath: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var result = 42.0 // primary
        if indexPath.section == 1 {
            result = 100.0 // hourly
        } else if indexPath.section == 2 {
            result = 38.0 // forecastdays
        } else if indexPath.section == 3 {
            result = 102.0 // forecastdescription
        } else if indexPath.section == 4 {
            result = 32.0 // secondary
        }
        
        return CGFloat(result)
    }

    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return primaryTitle
        }
        
        return ""
    }

    /*
     section 0  - primary
     section 1  - hourly
     section 2  - forecastdays
     section 3  - forecastdescription
     section 4  - secondary
     section 5  - otheritems
  */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return primaryItems.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            if forecastDaysData.count > 0 {
               return forecastDaysData.count - 1  // do not include today
            }
        } else if section == 3 {
            return 1
        } else if section == 4 {
            return secondaryItems.count
        } else if section == 5 {
            return conditionItems.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "WAHomeDataCell"
        
        if indexPath.section == 0 {
            reuseIdentifier = "WAHomePrimaryCell"
        } else if indexPath.section == 1 {
            reuseIdentifier = "WAHourlyCell"
        } else if indexPath.section == 2 {
            reuseIdentifier = "WAForecastDayCell"
        } else if indexPath.section == 3 {
            reuseIdentifier = "WAForecastDescriptionCell"
        } else if indexPath.section == 4 {
            reuseIdentifier = "WAHomeSecondaryCell"
        } else if indexPath.section == 5 {
            reuseIdentifier = "WAHomeDataCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if reuseIdentifier == "WAHourlyCell" {
            if let hourlyCell = cell as? WAHourlyCell {
                hourlyCell.collectionView.dataSource = hourlyCollectionData
                hourlyCell.collectionView.delegate = hourlyCollectionData
            }
        }

        return cell
    }

    
    // MARK: collectionView for hourly

    func updateCollectionForIconImage(iconName:String) {
        
        let hourlyCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        
        if let cell = self.tableView.cellForRowAtIndexPath(hourlyCellIndexPath) as? WAHourlyCell,
            let visible = cell.collectionView?.indexPathsForVisibleItems() {
            
            for indexPath in visible {
                if indexPath.row < hourlyCollectionData.hourlyPeriods.count {
                    let hourItem = hourlyCollectionData.hourlyPeriods[indexPath.row]
                    if let iconURL = hourItem["icon_url"] as? String where iconURL == iconName {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    }
                }
            }  // let visible
        }
    }


}



//  print("\(#function) Conditions \(refreshConditionsInProgress) Forecast \(refreshForecastInProgress) Hourly \(refreshHourlyInProgress)")
