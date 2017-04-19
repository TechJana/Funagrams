//
//  Settings.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/4/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import UIKit
import FunagramsKit

class Settings {
    enum Property: String {
        case Skill = "settingsSkill"
        case PlayMusic = "settingsMusic"
        case SkillAmateur = "settingsSkillAmateur"
        case SkillProfessional = "settingsSkillProfessional"
        case SkillExpert = "settingsSkillExpert"
        case AppVersion = "settingsAppVersion"
    }
    
    // Music toggle ON/OFF
    class var canPlayMusic: Bool {
        get {
            let settingsDefaults = UserDefaults.standard
            let isPlayMusic: Any? = settingsDefaults.value(forKey: Property.PlayMusic.rawValue)
            if isPlayMusic != nil {
                return (isPlayMusic as! Bool)
            }
            else {
                // set to true as default
                settingsDefaults.setValue(true, forKey: Property.PlayMusic.rawValue)
                return true
            }
        }
        set(newCanPlayMusic) {
            let settingsDefaults = UserDefaults.standard
            settingsDefaults.setValue(newCanPlayMusic, forKey: Property.PlayMusic.rawValue)
        }
    }
    
    // Skill last saved
    class var userSkill: Skill {
        get {
            let settingsDefaults = UserDefaults.standard
            let thisUserSkill: Any? = settingsDefaults.value(forKey: Property.Skill.rawValue)
            if thisUserSkill != nil {
                return Skill.settings(rawValue: thisUserSkill as! String)
            }
            else {
                // set to true as default
                settingsDefaults.setValue(Property.SkillAmateur.rawValue, forKey: Property.Skill.rawValue)
                return Skill.amateur
            }
        }
        set(newUserSkill) {
            let settingsDefaults = UserDefaults.standard
            settingsDefaults.setValue(newUserSkill.settings, forKey: Property.Skill.rawValue)
        }
    }

}
