//
//  WAHourlyCollectionDataSource.swift
//  WeatherApp
//
//  Created by JOSEPH KERR on 8/25/16.
//  Copyright © 2016 JOSEPH KERR. All rights reserved.
//

import Foundation
import UIKit


protocol WAHourlyCollectionDataDelegate: class {
    func hourlyCollection(controller:WAHourlyCollectionData, imageForIcon iconName:String) -> UIImage?
}


class WAHourlyCollectionData: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    weak var delegate: WAHourlyCollectionDataDelegate?
    
    var hourlyPeriods:[[String : AnyObject]] = []

    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView,
                        willDisplayCell cell: UICollectionViewCell,
                                        forItemAtIndexPath indexPath: NSIndexPath)
        
    {
        let hourCell = cell as! WAHourlyCollectionViewCell
        
        var topText = ""
        var bottomText = ""
        
        let hourItem = hourlyPeriods[indexPath.row]
        
        if let fcTime = hourItem["FCTTIME"] {
            
            if let hour = fcTime["hour"] as? String {
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

//            if let dow = fcTime["weekday_name_abbrev"] as? String {
//                bottomText += " \(dow)"
//            }

            if let ampm = fcTime["ampm"] as? String {
                bottomText += " \(ampm)"
            }
        }
        
        if let tempDict = hourItem["temp"] as? [String:AnyObject],
            let temp = tempDict["english"] as? String {
            topText = temp
        }

        let iconURL = hourItem["icon_url"] as! String
        let image = delegate?.hourlyCollection(self, imageForIcon: iconURL)
        
        hourCell.imageView.image = image
        
        hourCell.topLabel.text = topText
        hourCell.bottomLabel.text = bottomText
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        result = hourlyPeriods.count
        return result
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "WAHourlyCollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WAHourlyCollectionViewCell
        
        return cell
    }

    
}
