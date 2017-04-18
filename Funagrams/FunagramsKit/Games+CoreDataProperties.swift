//
//  Games+CoreDataProperties.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData


extension Games {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Games> {
        return NSFetchRequest<Games>(entityName: "Games")
    }

    @NSManaged public var gameId: Int64
    @NSManaged public var highScore: Int32
    @NSManaged public var maxScore: Int32
    @NSManaged public var anagram: Anagrams?
    @NSManaged public var level: Levels?
    @NSManaged public var mode: Modes?
    @NSManaged public var score: NSSet?

}

// MARK: Generated accessors for score
extension Games {

    @objc(addScoreObject:)
    @NSManaged public func addToScore(_ value: Scores)

    @objc(removeScoreObject:)
    @NSManaged public func removeFromScore(_ value: Scores)

    @objc(addScore:)
    @NSManaged public func addToScore(_ values: NSSet)

    @objc(removeScore:)
    @NSManaged public func removeFromScore(_ values: NSSet)

}
