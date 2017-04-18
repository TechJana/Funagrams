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
}
