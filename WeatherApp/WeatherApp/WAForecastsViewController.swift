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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.view.sendSubviewToBack(forecastTenContainerView)
        } else if sender.selectedSegmentIndex == 1 {
            self.view.sendSubviewToBack(forecastSomeContainerView)
        }
    }

    
    //WAEmbedForecastSome
    //WAEmbedForecastTen
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
