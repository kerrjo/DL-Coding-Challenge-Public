//
//  WAForecastsViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/22/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WAForecastsViewController: UIViewController {

    @IBOutlet weak var forecastSomeContainerView: UIView!
    @IBOutlet weak var forecastTenContainerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.selectedSegmentIndex = 0
        segmentValueChanged(segmentedControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            forecastTenContainerView.hidden = true
            forecastSomeContainerView.hidden = false
        } else if sender.selectedSegmentIndex == 1 {
            forecastTenContainerView.hidden = false
            forecastSomeContainerView.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WAEmbedForecastSome" {
            //print(segue.identifier )
        } else if segue.identifier == "WAEmbedForecastTen" {
            //print(segue.identifier )
        }
    }
    
}
