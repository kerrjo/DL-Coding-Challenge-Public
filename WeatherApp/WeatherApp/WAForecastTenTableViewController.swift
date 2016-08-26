//
//  WAForecastTenTableViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/22/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WAForecastTenTableViewController: WAForecastTableViewController {

    
    override func refreshData() {
        weatherInfo.getForecastTen()
    }
    

//    override func refreshTable(control:AnyObject?) {
//        
//        if !refreshInProgress {
//            
//            dismissHourlyCell()
//            
//            hourlyTenPeriods = nil
//            hourlyCollectionData.hourlyPeriods = []
//
//            if control == nil {
//                // Programmatically started
//                self.refreshControl?.beginRefreshing()
//                refreshInProgress = true
//                weatherInfo.getForecastTen()
//            } else {
////                refreshAll()
//                refreshInProgress = true
//                weatherInfo.getForecastTen()
//            }
//        }
//    }
    
    override func refreshAll() {
        refreshInProgress = true
        refreshForecastInProgress = true
        refreshHourlyInProgress = true
        weatherInfo.getHourlyTen()
        weatherInfo.getForecastTen()
    }


}
