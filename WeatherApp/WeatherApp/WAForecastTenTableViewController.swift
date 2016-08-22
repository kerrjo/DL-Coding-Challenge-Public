//
//  WAForecastTenTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/22/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WAForecastTenTableViewController: WAForecastTableViewController {

    
    override func refreshTable(control:AnyObject?) {
        if !refreshInProgress {
            refreshInProgress = true
            weatherInfo.getForecastTen()
        }
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
