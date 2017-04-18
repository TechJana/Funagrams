//
//  UIView+.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/2/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit

public extension UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    public func captureScreenshot() -> UIImage {
        return captureScreenshot(contentOffset: nil)
    }
    
    public func captureScreenshot(contentOffset: CGPoint?) -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        if (contentOffset != nil) {
            //need to translate the context down to the current visible portion of the scrollview
            UIGraphicsGetCurrentContext()?.translateBy(x: 0, y: -(contentOffset?.y)!)
        }
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // helps w/ our colors when blurring
        // feel free to adjust jpeg quality (lower = higher perf)
        let imageData: Data = UIImageJPEGRepresentation(image, 0.75)!
        image = UIImage(data: imageData)!
        
        return image
    }
}
