//
//  WAHomeViewController.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/28/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import UIKit

class WAHomeViewController: UIViewController, WAHomeTableDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func homeTable(controller:WAHomeTableViewController, primaryLocationTitle title:String) {
        locationLabel.text = title
    }

    //WAEmbedHomeTableSegue
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "WAEmbedHomeTableSegue" {
            if let vc = segue.destinationViewController as? WAHomeTableViewController {
                vc.delegate = self
            }
        }
    }

}
