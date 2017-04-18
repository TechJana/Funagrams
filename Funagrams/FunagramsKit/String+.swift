//
//  String+.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation

public extension String {
    public func localized(langShortCode: String) ->String {
        var langBundle: Bundle?
        
        let proxyBundle = Bundle(identifier: FunagramsKit.BUNDLE_ID)
//        if proxyBundle == nil {
//            proxyBundle = Bundle(identifier: FunagramsKit.WATCH_KIT_BUNDLE_ID)
//        }
        
        // check if the localization exists
        if proxyBundle!.path(forResource: langShortCode, ofType: "lproj") == nil {
            // default to Base.lproj if localization is missing
            langBundle = Bundle(path: proxyBundle!.path(forResource: "Base", ofType: "lproj")!)
        }
        else {
            langBundle = Bundle(path: proxyBundle!.path(forResource: langShortCode, ofType: "lproj")!)
        }
        if langBundle == nil {
            langBundle = proxyBundle!
        }
        return langBundle!.localizedString(forKey: self, value: nil, table: nil)
    }
    
    public func localized() ->String {
        return localized(langShortCode: Languages.Current.ShortCode())
    }
}
