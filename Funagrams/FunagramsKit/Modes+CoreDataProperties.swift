//
//  Modes+CoreDataProperties.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData


extension Modes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Modes> {
        return NSFetchRequest<Modes>(entityName: "Modes")
    }

    @NSManaged public var hintsPercentile: Float
    @NSManaged public var modeDescription: String?
    @NSManaged public var modeId: Int32
    @NSManaged public var games: NSSet?

}

// MARK: Generated accessors for games
extension Modes {

    @objc(addGamesObject:)
    @NSManaged public func addToGames(_ value: Games)

    @objc(removeGamesObject:)
    @NSManaged public func removeFromGames(_ value: Games)

    @objc(addGames:)
    @NSManaged public func addToGames(_ values: NSSet)

    @objc(removeGames:)
    @NSManaged public func removeFromGames(_ values: NSSet)

}
