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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func homeTable(controller:WAHomeTableViewController, primaryLocationTitle title:String) {
        locationLabel.text = title
    }

    //WAEmbedHomeTableSegue
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "WAEmbedHomeTableSegue" {
            if let vc = segue.destinationViewController as? WAHomeTableViewController {
                vc.delegate = self
                
            }
        }
    }

}
