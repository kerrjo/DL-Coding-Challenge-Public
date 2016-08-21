//
//  WAForecastTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/21/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit



class WAForecastTableViewController: UITableViewController, WAWeatherInfoDelegate {

    var weatherInfo = WAWeatherInfo()
    
    var conditionItems:[String] = []
    var currentConditionsDict:[String : AnyObject]?
    

    var forecastPeriods:[[String : AnyObject]] = []

    private var imagePlaceholder = UIImage(named: "imageplaceholder")!
    private var imageCache: NSCache = NSCache()
    
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
        weatherInfo.getForecast()
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
        
        forecastPeriods = dayPeriods

        self.tableView.reloadData()

        for result in forecastPeriods {
            let icon = result["icon"] as! String
            let iconURLString = result["icon_url"] as! String

            self.imageFor(icon, imageURLString: iconURLString)
        }
    }

    
    
    //    "forecast": {
    //    "txt_forecast": {
    //    "date": "2:00 PM PDT",
    
    //    "forecastday": [{
    //    "period": 0,
    //    "icon": "partlycloudy",
    //    "icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
    //    "title": "Tuesday",
    //    "fcttext": "Partly cloudy in the morning, then clear. High of 68F. Breezy. Winds from the West at 10 to 25 mph.",
    //    "fcttext_metric": "Partly cloudy in the morning, then clear. High of 20C. Windy. Winds from the West at 20 to 35 km/h.",
    //    "pop": "0"
    //    }, {
    //    "period": 1,
    //    "icon": "partlycloudy",
    //    "icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",
    //    "title": "Tuesday Night",
    //    "fcttext": "Mostly cloudy. Fog overnight. Low of 50F. Winds from the WSW at 5 to 15 mph.",
    //    "fcttext_metric": "Mostly cloudy. Fog overnight. Low of 10C. Breezy. Winds from the WSW at 10 to 20 km/h.",
    //    "pop": "0"
    //    }, {
    //    "period": 2,
    //    "icon": "partlycloudy
    //
    

    
    
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

        cell.imageView!.image = self.imageFor(icon)
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    func imageFor(iconName:String) -> UIImage? {
        
        var result: UIImage?
        if let cachedImage = imageCache.objectForKey(iconName) {
            result = cachedImage as? UIImage
        } else {
            result = imagePlaceholder
        }
        return result
    }
    

    func imageFor(iconName:String, imageURLString:String) -> Void {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let imageURL = NSURL(string: imageURLString),
                imageData = NSData(contentsOfURL:imageURL),
                iconImage = UIImage(data: imageData) {
                
                self.imageCache.setObject(iconImage, forKey: iconName)
                
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    
    func updateFor(iconName:String) -> Void {
        
        if let visible = self.tableView.indexPathsForVisibleRows {
            for indexPath in visible {
                if indexPath.row < self.forecastPeriods.count {
                    
                    let forecastPeriod = forecastPeriods[indexPath.row]
                    let icon = forecastPeriod["icon"] as! String

                    //let youtubeVideo = (self.searchResults?[indexPath.row])!
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

    
    
    


}
