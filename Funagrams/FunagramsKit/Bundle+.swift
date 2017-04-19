//
//  Bundle+.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/18/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation

public extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
