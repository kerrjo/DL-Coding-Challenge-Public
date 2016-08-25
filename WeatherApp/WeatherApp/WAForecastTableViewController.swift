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


class WAForecastTableViewController: UITableViewController, WADataStoreDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var weatherInfo = WADataStore()

    var forecastPeriods:[[String : AnyObject]] = []
    var hourlyPeriods:[[String : AnyObject]]?
    var hourlyTenPeriods:[[[String : AnyObject]]] = []

    //var hourlyPeriods:[[String : AnyObject]] = []
    
    private var imagePlaceholder = UIImage(named: "imageplaceholder")!
    private var imageCache: NSCache = NSCache()
    
    var refreshInProgress = false
    var revealRow: Int?
    
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
        
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAForecastRevealCell {
                
                if let visible = cell.collectionView?.indexPathsForVisibleItems() {
                    for indexPath in visible {
                        if let hourlyItems = hourlyPeriods {
                            if indexPath.row < hourlyItems.count {
                                
                                let hourItem = hourlyItems[indexPath.row]
                                let icon = hourItem["icon"] as! String
                                
                                if icon == iconName {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        //self.collectionView.beginUpdates()
                                        cell.collectionView?.reloadItemsAtIndexPaths([indexPath])
                                        //self.tableView.endUpdates()
                                    }
                                }
                            }
                        }
                    }
                }  // let visible
                
            }
            
        }
        
    }
    
    func dataStore(controller: WADataStore, didReceiveDayForecast dayPeriods:[[String : AnyObject]]) {
        
        forecastPeriods = dayPeriods
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }

        refreshInProgress = false
        self.refreshControl?.endRefreshing()
    }
    
    func dataStore(controller: WADataStore, didReceiveHourly hourPeriods:[[String : AnyObject]]) {
        
        hourlyPeriods = hourPeriods
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAForecastRevealCell {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.collectionView?.reloadData()
                }
            }
            
        }
        //refreshInProgress = false
    }
    
    func dataStore(controller: WADataStore, didReceiveHourlyTen hourPeriods:[[[String : AnyObject]]]) {
        
        print(#function)
        
        hourlyTenPeriods = hourPeriods
        
        selectPeriod()
        
        if let revealIndex = revealRow {
            
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? WAForecastRevealCell {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.collectionView?.reloadData()
                    cell.activity.stopAnimating()
                }
            }
            
        }
        //refreshInProgress = false
    }


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

    
    func selectPeriod() {
        if let revealIndex = revealRow {
            var dayIndex = 0
            
            if revealIndex == 0 || revealIndex == 1 {
                dayIndex = 0
            } else if revealIndex == 2 || revealIndex == 3 {
                dayIndex = 1
            } else if revealIndex == 4 || revealIndex == 5 {
                dayIndex = 2
            } else if revealIndex == 6 || revealIndex == 7 {
                dayIndex = 3
            }
            
            hourlyPeriods = hourlyTenPeriods[dayIndex]
            
            print("dayIndex \(dayIndex)")
            if let hourlyItems = hourlyPeriods {
                for hourItem in hourlyItems {
                    weatherInfo.printHourItem(hourItem)
                }
            }
            
        }
    }
    


    // MARK: -

    func revealHourlyCell() {

        if let revealIndex = revealRow {
            
            if let _ = hourlyPeriods {
                selectPeriod()
            } else {
                weatherInfo.getHourlyTen()
            }
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    func dismissHourlyCell() {
        
        if let revealIndex = revealRow {
            let indexPath = NSIndexPath(forRow: revealIndex + 1, inSection: 0)
            revealRow = nil
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }

    
    func dismissRevealHourlyCell(fromIndex:Int, toIndex:Int) {
        
        if let revealIndex = revealRow {
            let deleteIndexPath = NSIndexPath(forRow: fromIndex, inSection: 0)
            let insertIndexPath = NSIndexPath(forRow: toIndex, inSection: 0)
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }

    

    // MARK: - Table view delegate
    
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
            
            let icon = forecastPeriod["icon"] as! String
            
            cell.imageView!.image = self.weatherInfo.imageFor(icon)
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
                dismissHourlyCell()
                
            } else {

                var normalizedRow = indexPath.row
                if normalizedRow > revealIndex + 1 {
                    normalizedRow -= 1
                }
                dismissHourlyCell()
                revealRow = normalizedRow
                revealHourlyCell()
                
//
//                let fromIndex = revealIndex + 1
//                let toIndex = indexPath.row
//                revealRow = normalizedRow
//                dismissRevealHourlyCell(fromIndex, toIndex: toIndex)
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
                result = 110.0
            }
        }

        return CGFloat(result)
    }

    
    // MARK: - Table view data source

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
            if indexPath.row  == revealIndex + 1 {
                reuseIdentifier = "WAForecastRevealCell"
            }
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        if reuseIdentifier == "WAForecastRevealCell" {
            if let revealCell = cell as? WAForecastRevealCell {
                revealCell.collectionView.dataSource = self
                revealCell.collectionView.delegate = self
                if let _ = hourlyPeriods {
                    revealCell.collectionView.reloadData()
                } else {
                    revealCell.activity.startAnimating()
                }

            }
        }

        // Configure the cell...
        return cell
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView,
                                 willDisplayCell cell: UICollectionViewCell,
                                                 forItemAtIndexPath indexPath: NSIndexPath)
        
    {
        let hourCell = cell as! WAHourlyCollectionViewCell
        
        var topText = ""
        var bottomText = ""
        
        if let hourlyItems = hourlyPeriods {
            
            let hourItem = hourlyItems[indexPath.row]
            
            //print(period)
            if let fcTime = hourItem["FCTTIME"] {
                
                if let hour = fcTime["hour"] as? String {
                    //print(hour)
                    
                    let hourInt:Int? = Int(hour)
                    if let intHour = hourInt {
                        if intHour > 12 {
                            bottomText = "\(intHour - 12)"
                        } else {
                            bottomText = "\(intHour)"
                        }
                    } else {
                        bottomText = hour
                    }
                    
                }
                
                if let ampm = fcTime["ampm"] as? String {
                    bottomText += " \(ampm)"
                }
//                if let dow = fcTime["weekday_name_abbrev"] as? String {
//                    bottomText += "\n\(dow)"
//                }
                
                //            if let hourText = fcTime["civil"] as? String {
                //                //print(hourText)
                //            }
            }
            
            if let tempDict = hourItem["temp"] as? [String:AnyObject],
                let temp = tempDict["english"] as? String {
                //print(temp)
                topText = temp
            }
            let icon = hourItem["icon"] as! String
            
            hourCell.imageView.image = weatherInfo.imageFor(icon)
            
        }
        
        hourCell.topLabel.text = topText
        hourCell.bottomLabel.text = bottomText

    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        if let hourlyItems = hourlyPeriods {
            result = hourlyItems.count
        }
        return result
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "WAHourlyCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WAHourlyCollectionViewCell
        
        return cell
    }


}


