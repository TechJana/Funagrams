//
//  Scores+CoreDataProperties.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData


extension Scores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scores> {
        return NSFetchRequest<Scores>(entityName: "Scores")
    }

    @NSManaged public var playedOn: NSDate?
    @NSManaged public var score: Int32
    @NSManaged public var scoreId: Int64
    @NSManaged public var starsScored: Float
    @NSManaged public var game: Games?

}
