//
//  GameCenter.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation

public enum Skill: Int {
    case none = -1
    case amateur = 1
    case professional = 2
    case expert = 3
    
    public var description: String {
        switch self {
        case .amateur:
            return "amateur"
        case .professional:
            return "professional"
        case .expert:
            return "expert"
        default:
            return ""
        }
    }
    
    public var imageName: String {
        switch self {
        case .amateur:
            return "BtnSkillAmateurImage"
        case .professional:
            return "BtnSkillProfessionalImage"
        case .expert:
            return "BtnSkillExpertImage"
        default:
            return ""
        }
    }
    
    public var settings: String {
        switch self {
        case .amateur:
            return "settingsSkillAmateur"
        case .professional:
            return "settingsSkillProfessional"
        case .expert:
            return "settingsSkillExpert"
        default:
            return ""
        }
    }
    
    public static func settings(rawValue: String) -> Skill {
        switch rawValue {
        case "settingsSkillAmateur":
            return Skill.amateur
        case "settingsSkillProfessional":
            return Skill.professional
        case "settingsSkillExpert":
            return Skill.expert
        default:
            return Skill.none
        }
    }
}

public enum Level: Int {
    case none = -1
    case Level01 = 1
    case Level02 = 2
    case Level03 = 3
    case Level04 = 4
    case Level05 = 5
    case Level06 = 6
    case Level07 = 7
    case Level08 = 8
    case Level09 = 9
    case Level10 = 10
    case Level11 = 11
    case Level12 = 12
    case Level13 = 13
    case Level14 = 14
    case Level15 = 15
    case Level16 = 16
    case Level17 = 17
    case Level18 = 18
    case Level19 = 19
    case Level20 = 20
    
    
    public var description: String {
        switch self {
        case .Level01:
            return "Level 1"
        case .Level02:
            return "Level 2"
        case .Level03:
            return "Level 3"
        case .Level04:
            return "Level 4"
        case .Level05:
            return "Level 5"
        case .Level06:
            return "Level 6"
        case .Level07:
            return "Level 7"
        case .Level08:
            return "Level 8"
        case .Level09:
            return "Level 9"
        case .Level10:
            return "Level 10"
        case .Level11:
            return "Level 11"
        case .Level12:
            return "Level 12"
        case .Level13:
            return "Level 13"
        case .Level14:
            return "Level 14"
        case .Level15:
            return "Level 15"
        case .Level16:
            return "Level 16"
        case .Level17:
            return "Level 17"
        case .Level18:
            return "Level 18"
        case .Level19:
            return "Level 19"
        case .Level20:
            return "Level 20"
        default:
            return ""
        }
    }
    
    public var LeaderBoard: String {
        switch self {
        case .Level01:
            return "com.pluggables.funagrams.leaderBoard.Level01"
        case .Level02:
            return "com.pluggables.funagrams.leaderBoard.Level02"
        case .Level03:
            return "com.pluggables.funagrams.leaderBoard.Level03"
        case .Level04:
            return "com.pluggables.funagrams.leaderBoard.Level04"
        case .Level05:
            return "com.pluggables.funagrams.leaderBoard.Level05"
        case .Level06:
            return "com.pluggables.funagrams.leaderBoard.Level06"
        case .Level07:
            return "com.pluggables.funagrams.leaderBoard.Level07"
        case .Level08:
            return "com.pluggables.funagrams.leaderBoard.Level08"
        case .Level09:
            return "com.pluggables.funagrams.leaderBoard.Level09"
        case .Level10:
            return "com.pluggables.funagrams.leaderBoard.Level10"
        case .Level11:
            return "com.pluggables.funagrams.leaderBoard.Level11"
        case .Level12:
            return "com.pluggables.funagrams.leaderBoard.Level12"
        case .Level13:
            return "com.pluggables.funagrams.leaderBoard.Level13"
        case .Level14:
            return "com.pluggables.funagrams.leaderBoard.Level14"
        case .Level15:
            return "com.pluggables.funagrams.leaderBoard.Level15"
        case .Level16:
            return "com.pluggables.funagrams.leaderBoard.Level16"
        case .Level17:
            return "com.pluggables.funagrams.leaderBoard.Level17"
        case .Level18:
            return "com.pluggables.funagrams.leaderBoard.Level18"
        case .Level19:
            return "com.pluggables.funagrams.leaderBoard.Level19"
        case .Level20:
            return "com.pluggables.funagrams.leaderBoard.Level20"
        default:
            return "com.pluggables.funagrams.leaderBoard.HighScore"
        }
    }
}
