//
//  Languages.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation

public class Languages {
    public enum ShortCode: String {
        case None = ""
        case Tamil = "ta"
        case English = "en"
        case Hindi = "hi"
        case Telugu = "te"
        case Kannada = "kn"
        case Sanskrit = "sa"
        case French = "fr"
        case German = "de"
        case Arabic = "ar"
        case Russian = "ru"
        case Chinese = "zh"
        case Sinhalese = "si"
        case Malay = "ms"
        case Bengali = "bn"
        case Swedish = "sv"
        case Latin = "la"
        case Polish = "pl"
        case Italian = "it"
        case Marathi = "mr"
        case Malayalam = "ml"
        case Fijian = "fj"
        case Konkani = "--"
    }
    
    public enum ShortCodeWithCountryCode: String {
        case None = ""
        case Tamil = "ta_IN"
        case English = "en_US"
        case Hindi = "hi_IN"
        case Russian = "ru_RU"
    }
    
    public class Current {
        private static var _ShortCode = Locale.preferredLanguages[0] // get current locale / language code
        
        public static func ShortCode() ->String {
            if _ShortCode.characters.count > 2 {
                _ShortCode = _ShortCode.substring(to: _ShortCode.index(_ShortCode.startIndex, offsetBy: 2))
            }
            return _ShortCode
        }
        
        public static func IsTamil() ->Bool {
            return (ShortCode() == Languages.ShortCode.Tamil.rawValue)
        }
    }
}
