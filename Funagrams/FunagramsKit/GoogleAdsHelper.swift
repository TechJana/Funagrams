//
//  GoogleAdsHelper.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/19/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation

public class GoogleAdsHelper {
    public enum Properties: String {
        case Banner = "AD_UNIT_ID_FOR_BANNER"
        case Interstitial = "AD_UNIT_ID_FOR_INTERSTITIAL"
        case AppId = "GOOGLE_APP_ID"
    }
    
    public class func readPropertyFromGoogleService(propertyName: Properties) -> String {
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data
        let plistPath: String? = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")! //the path of the data
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {//convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListForamt) as! [String:AnyObject]
            
        } catch {
            print("Error reading plist: \(error), format: \(propertyListForamt)")
        }
        return plistData[propertyName.rawValue] as! String
    }
}
