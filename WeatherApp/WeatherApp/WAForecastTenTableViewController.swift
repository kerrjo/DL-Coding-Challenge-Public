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
            if control == nil {
                // Programmatically started
                self.refreshControl?.beginRefreshing()
            }
            
            refreshInProgress = true
            weatherInfo.getForecastTen()
        }
    }

}
