//
//  WAHomeTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/28/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit


protocol WAHomeTableDelegate : class {
    func homeTable(controller:WAHomeTableViewController, primaryLocationTitle title:String)
}

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



class WAHomeTableViewController: UITableViewController, WADataStoreDelegate , WAHourlyCollectionDataDelegate{

    var weatherInfo = WADataStore()

    weak var delegate:WAHomeTableDelegate?
    
    var optionTitle = ""
    var primaryTitle = ""
    
    var primaryItems:[String] = []
    var primaryConditionsDict:[String : AnyObject]?
    var conditionItems:[String] = []
    var currentConditionsDict:[String : AnyObject]?
    
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
        print(#function)
        if !refreshConditionsInProgress && !refreshForecastInProgress && !refreshHourlyInProgress {
            
            print("\(#function) finished!")

            refreshInProgress = false
            self.refreshControl?.endRefreshing()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
            
            self.updateTableHeaderData()
        }
    }

    
    func updateTableHeaderData() {
        
        if forecastDaysData.count > 0 {
            
            let forecastDayData = forecastDaysData[0]
            
            if let highData = forecastDayData["high"],
                let tempf = highData["fahrenheit"] as? String {
                tableHeaderHighLabel.text = tempf
            }
            
            if let highData = forecastDayData["low"],
                let tempf = highData["fahrenheit"] as? String {
                tableHeaderLowLabel.text = tempf
            }
            
            //    if let dateInfo = forecastDayData["date"],
            //    let dow = dateInfo["weekday"] as? String {
            //    dayCell.dayLabel.text = dow
            //    }
            
        }
        if let tempf = currentConditionsDict?["temp_f"] as? Int {
            tableHeaderPrimaryLabel.text = "\(tempf)"
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

        refreshConditionsInProgress = false
        checkRefreshFinished()
        
    }
    
    //        refreshInProgress = false
    //        self.refreshControl?.endRefreshing()

    
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
                
                if indexPath.section == 2 {
                    if indexPath.row < self.forecastDaysData.count {
                        
                        let forecastPeriod = forecastDaysData[indexPath.row]
                        
                        let iconURL = forecastPeriod["icon_url"] as! String
                        if iconURL == iconName {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.beginUpdates()
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                self.tableView.endUpdates()
                            }
                            
                        }
                    }
                } else {
                    //print("non standard cell")
                }
            }
        }  // let visible
    }
    
    
    
    // MARK: - Configure Cells Methods

    func configureDisplayPrimaryCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        let conditionItem = primaryItems[indexPath.row]
        cell.textLabel!.text = conditionItem
        
        if let detailText = primaryConditionsDict?[conditionItem] as? String {
            cell.detailTextLabel!.text = detailText
        } else {
            cell.detailTextLabel!.text = nil
        }
    }

    func configureDisplayHourlyCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let hourlyCell = cell as? WAHourlyCell {
            hourlyCell.collectionView?.reloadData()
            if !refreshInProgress {
                hourlyCell.activity.stopAnimating()
            }
        }
    }

    func configureDisplayForecastDayCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let dayCell = cell as? WAForecastDayCell where forecastDaysData.count > 0 {
            
            let forecastDayData = forecastDaysData[indexPath.row]
            
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
            
            let iconURL = forecastDayData["icon_url"] as! String
            
            dayCell.iconImageView!.image = self.weatherInfo.imageFor(iconURL)
        }
    }

    func configureDisplayForecastDescriptionCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
            //                else {
            //                    print("no forecastPeriods")
            //                }
            
            descriptionCell.descriptionLabel.text = descriptionText
        }
    }

    func configureDisplayHomeDataCell(cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
            // "WAHomeDataCell"
            configureDisplayHomeDataCell(cell, forRowAtIndexPath: indexPath)
        }
        
    }

    
    override func tableView(tableView: UITableView,
                            heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var result = 42.0 // primary
        if indexPath.section == 1 {
            result = 100.0 // hourly
        } else if indexPath.section == 2 {
            result = 38.0 // forecastdays
        } else if indexPath.section == 3 {
            result = 102.0 // forecastdescription
        }
        
        return CGFloat(result)
    }


    
    // MARK: - Table view data source

    
    /*
     section 0  - primary
     section 1  - hourly
     section 2  - forecastdays
     section 3  - forecastdescription
     section 4  - otheritems
  */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 {
            return primaryItems.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return forecastDaysData.count
        } else if section == 3 {
            return 1
        } else if section == 4 {
            return conditionItems.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
// WAHomePrimaryCell
// WAHomeDataCell
// WAForecastDayCell
// WAHourlyCell
// WAForecastDescriptionCell

        
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

  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func updateCollectionForIconImage(iconName:String) {
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAHourlyCell {
            
            if let visible = cell.collectionView?.indexPathsForVisibleItems() {
                for indexPath in visible {
                    if indexPath.row < hourlyCollectionData.hourlyPeriods.count {
                        let hourItem = hourlyCollectionData.hourlyPeriods[indexPath.row]
                        let iconURL = hourItem["icon_url"] as! String
                        if iconURL == iconName {
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            }
                        }
                    }
                }
            }  // let visible
        }
    }


}



// Uncomment the following line to preserve selection between presentations
// self.clearsSelectionOnViewWillAppear = false

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// self.navigationItem.rightBarButtonItem = self.editButtonItem()


//            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
//            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAHourlyCell {
//
//                dispatch_async(dispatch_get_main_queue()) {
//                    cell.collectionView?.reloadData()
//                    cell.activity.stopAnimating()
//                }
//            }


//        hourlyPeriods = hourPeriods
//        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
//        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAHourlyCell {
//
//            dispatch_async(dispatch_get_main_queue()) {
//                cell.collectionView?.reloadData()
//                cell.activity.stopAnimating()
//            }
//        }

//        refreshInProgress = false



