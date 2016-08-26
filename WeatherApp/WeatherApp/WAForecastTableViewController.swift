//
//  WAForecastTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WAForecastRevealCell: UITableViewCell {
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
}


class WAForecastTableViewController: UITableViewController, WADataStoreDelegate, WAHourlyCollectionDataDelegate {

    var weatherInfo = WADataStore()
    
    var forecastPeriods:[[String : AnyObject]] = []
    var hourlyTenPeriods:[[[String : AnyObject]]]?

    var hourlyCollectionData = WAHourlyCollectionData()
    
    var refreshInProgress = false
    var refreshForecastInProgress = false
    var refreshHourlyInProgress = false

    var revealRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherInfo.delegate = self
        hourlyCollectionData.delegate = self
        
        self.clearsSelectionOnViewWillAppear = false
        
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
                refreshInProgress = true
                refreshData()
                //weatherInfo.getForecast()

            } else {
                dismissHourlyCell(false)
                
                hourlyTenPeriods = nil
                hourlyCollectionData.hourlyPeriods = []

//                refreshAll()
                refreshInProgress = true
                refreshData()
//                weatherInfo.getForecast()
            }
        }
    }
    
    func refreshAll() {
        refreshInProgress = true
        refreshForecastInProgress = true
        refreshHourlyInProgress = true
        refreshData()
        //weatherInfo.getForecast()
        weatherInfo.getHourlyTen()
    }

    func refreshData() {
        weatherInfo.getForecast()
    }

  
    // Mark: WAHourlyCollectionDataDelegate
    
    func hourlyCollection(controller:WAHourlyCollectionData, imageForIcon iconName:String) -> UIImage? {
        
        return self.weatherInfo.imageFor(iconName)
    }
    
    // Mark: WADataStoreDelegate
    
    func dataStore(controller: WADataStore, updateForIconImage iconName:String) {

        updateTableForIconImage(iconName)
        updateCollectionForIconImage(iconName)
    }
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        forecastPeriods = dayPeriods
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }

        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }
    
    //        refreshForecastInProgress = false
    //        if refreshInProgress && !refreshHourlyInProgress {
    //            refreshInProgress = false
    //            self.refreshControl?.endRefreshing()
    //        }

    //        if let revealIndex = self.revealRow {
    //            let indexPath = NSIndexPath(forRow: revealIndex, inSection: 0)
    //            self.tableView.selectRowAtIndexPath(indexPath,
    //                                                animated: false,
    //                                                scrollPosition: .None)
    //        }

    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]]) {
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, didReceiveHourlyTen hourPeriods:[[[String : AnyObject]]]) {
        
        hourlyTenPeriods = hourPeriods
        
        selectPeriod()
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAForecastRevealCell {
                
                dispatch_async(dispatch_get_main_queue()) {
                    cell.collectionView?.reloadData()
                    cell.activity.stopAnimating()
                }
                
//                let delaySeconds = Double(0.25)
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_SEC)))
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    self.tableView.beginUpdates()
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//                    self.tableView.endUpdates()
//                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    self.tableView.endUpdates()
                }
            }
        }
        
        refreshHourlyInProgress = false
    }

    //        if refreshInProgress && !refreshForecastInProgress {
    //            refreshInProgress = false
    //            self.refreshControl?.endRefreshing()
    //        }


    func dataStore(controller: WADataStore, didReceiveCurrentConditions conditionItems:[String],
                   conditionsDict:[String : AnyObject],
                   primaryItems:[String],
                   primaryDict:[String : AnyObject]
        ){
        // EMPTY Impl
    }
    
    func dataStore(controller: WADataStore, primaryLocationTitle:String) {
        // EMPTY Impl
    }

    func dataStore(controller: WADataStore, didReceiveSatteliteImage image:UIImage) {
        // EMPTY Impl
    }

    
    // MARK: Helper
    
    func selectPeriod() {
        if let revealIndex = revealRow {
            var dayIndex = 0
            dayIndex = revealIndex / 2
            if let hourlyTenItems = hourlyTenPeriods {
                hourlyCollectionData.hourlyPeriods = hourlyTenItems[dayIndex]
            }
            
//            for hourlyItem in hourlyCollectionData.hourlyPeriods {
//                weatherInfo.printHourItem(hourlyItem)
//            }
        }
    }


    func isNightForRow(index:Int) -> Bool {
        var result = false
        let forecastPeriod = forecastPeriods[index]
        if let icon = forecastPeriod["icon"] as? String {
            result = icon.hasPrefix("nt_")
        }
        return result
    }


    // MARK:- UITableview

    func revealHourlyCell() {

        if let revealIndex = revealRow {
            if let _ = hourlyTenPeriods {
                selectPeriod()
            } else {
                weatherInfo.getHourlyTen()
            }
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            self.tableView.endUpdates()
            
            self.tableView.rectForRowAtIndexPath(indexPath)
            self.tableView.scrollRectToVisible(self.tableView.rectForRowAtIndexPath(indexPath), animated: true)
        }
    }
    
    func dismissHourlyCell(animated:Bool) {
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            revealRow = nil
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animated ? .Top : .None)
            self.tableView.endUpdates()
        }
    }
    
    // Work In Progress : perform delete and insert simultaneously
    func dismissRevealHourlyCell(fromIndex:Int, toIndex:Int) {
        let deleteIndexPath = NSIndexPath(forRow: fromIndex, inSection: 0)
        let insertIndexPath = NSIndexPath(forRow: toIndex, inSection: 0)
        self.tableView.beginUpdates()
        revealRow = nil
        self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Automatic)
        revealRow = toIndex - 1
        selectPeriod()
        self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    
    func updateTableForIconImage(iconName:String) {
        if let visible = self.tableView.indexPathsForVisibleRows {
            for indexPath in visible {
                
                var normalizedRow = indexPath.row
                var standardCell = true
                
                if let revealIndex = revealRow {
                    if normalizedRow > revealIndex + 1 {
                        normalizedRow -= 1
                    } else if normalizedRow == revealIndex + 1  {
                        standardCell = false
                    }
                }
                
                if standardCell {
                    if normalizedRow < self.forecastPeriods.count {
                        
                        let forecastPeriod = forecastPeriods[normalizedRow]
                        
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
    
    

    // MARK: Table view delegate
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath)
    {
        var normalizedRow = indexPath.row

        var standardCell = true
        
        if let revealIndex = revealRow {
            if normalizedRow > revealIndex + 1 {
                normalizedRow -= 1
            } else if normalizedRow == revealIndex + 1  {
                standardCell = false
            }
        }

        if standardCell {
            
            let forecastPeriod = forecastPeriods[normalizedRow]
            
            if let titleText = forecastPeriod["title"] as? String {
                cell.textLabel!.text = titleText
            }
            
            if let detailText = forecastPeriod["fcttext"] as? String {
                cell.detailTextLabel!.text = detailText
            }
            
            let iconURL = forecastPeriod["icon_url"] as! String
            
            cell.imageView!.image = self.weatherInfo.imageFor(iconURL)
            
            if let revealIndex = revealRow {
                if indexPath.row == revealIndex {
                    let selectIndexPath = NSIndexPath(forRow: revealIndex, inSection: 0)
                    self.tableView.selectRowAtIndexPath(selectIndexPath, animated: false, scrollPosition: .None)
                }
            }

        } else {
            
            var isNight = false
            if let revealIndex = revealRow {
                isNight = isNightForRow(revealIndex)
            }

            if let revealCell = cell as? WAForecastRevealCell {
                if let _ = hourlyTenPeriods {
                    revealCell.collectionView.reloadData()
                    positionCollection(revealCell, isNight:isNight)
                } else {
                    revealCell.activity.startAnimating()
                }
            }
        }
        
    }
    
    override func tableView(tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? {
        let result = UITableViewHeaderFooterView()
        result.contentView.backgroundColor = UIColor.clearColor()
        return result
    }

    
    override func tableView(tableView: UITableView,
                              didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if let revealIndex = revealRow {
            
            if indexPath.row == revealIndex {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                dismissHourlyCell(true)
                
            } else {

                var normalizedRow = indexPath.row
                if normalizedRow < revealIndex  {
                    normalizedRow += 1
                }
                
//                dismissHourlyCell(false)
//                revealRow = normalizedRow
//                revealHourlyCell()
                
                let fromIndex = revealIndex + 1
                let toIndex = normalizedRow
                dismissRevealHourlyCell(fromIndex, toIndex: toIndex)
            }
            
        } else {
            revealRow = indexPath.row
            revealHourlyCell()
        }
        
    }
    
    override func tableView(tableView: UITableView,
                              heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var result = 64.0
        if let revealIndex = revealRow {
            if indexPath.row == revealIndex + 1 {
                result = 100.0
            }
        }

        return CGFloat(result)
    }

    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var resultCount = forecastPeriods.count
        if let _ = revealRow {
            resultCount += 1
        }

        return resultCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier = "WAForecastPeriodCell"

        if let revealIndex = revealRow {
            if indexPath.row == revealIndex + 1 {
                reuseIdentifier = "WAForecastRevealCell"
            }
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if reuseIdentifier == "WAForecastRevealCell" {
            if let revealCell = cell as? WAForecastRevealCell {
                //print("revealCell \(reuseIdentifier)")
                revealCell.collectionView.dataSource = hourlyCollectionData
                revealCell.collectionView.delegate = hourlyCollectionData
            }
        }

        return cell
    }
    
    
    // MARK:- UICollectionView
    
    
    func positionCollection(revealCell:WAForecastRevealCell, isNight:Bool) {
        //print(#function)
        
        if isNight {
            if hourlyCollectionData.hourlyPeriods.count > 0 {
                let endIndex = hourlyCollectionData.hourlyPeriods.count - 1
                let endIndexPath = NSIndexPath(forItem: endIndex, inSection: 0)
                revealCell.collectionView.scrollToItemAtIndexPath(endIndexPath, atScrollPosition: .Right, animated:false)
            }
        } else {
            if hourlyCollectionData.hourlyPeriods.count < 23 {
                // Less than a full day must be current day
                let startIndex = 0
                let startIndexPath = NSIndexPath(forItem: startIndex, inSection: 0)
                revealCell.collectionView.scrollToItemAtIndexPath(startIndexPath, atScrollPosition: .Left, animated:false)
            } else {
                // Full day
                let startIndex = hourlyCollectionData.hourlyPeriods.count / 2
                let startIndexPath = NSIndexPath(forItem: startIndex, inSection: 0)
                revealCell.collectionView.scrollToItemAtIndexPath(startIndexPath, atScrollPosition: .CenteredHorizontally, animated:false)
            }
        }
    }

    
    
    func updateCollectionForIconImage(iconName:String) {
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAForecastRevealCell {
                
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
    

}


