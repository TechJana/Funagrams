//
//  UIUtility.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/2/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit

public class Helper {
    public class func dispatchOnMainQueueAfter(_ delay:Double, closure:@escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay, qos: DispatchQoS.userInteractive, flags: DispatchWorkItemFlags.enforceQoS, execute: closure)
    }
    
    public class func distanceBetweenPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let xDistance = firstPoint.x - secondPoint.x
        let yDistance = firstPoint.y - secondPoint.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
    
    public class func askToRateApp(appID: String) {
        let reviewString = "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8&action=write-review"
        
        if let checkURL = URL(string: reviewString) {
            Helper.open(url: checkURL)
        } else {
            print("invalid url")
        }
    }
    
    public class func open(url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else {
            if UIApplication.shared.openURL(url) {
                print("Open \(url): success")
            }
        }
    }
}
