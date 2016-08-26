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

}
