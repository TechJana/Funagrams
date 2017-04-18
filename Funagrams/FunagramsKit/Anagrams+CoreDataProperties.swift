//
//  Anagrams+CoreDataProperties.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData


extension Anagrams {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Anagrams> {
        return NSFetchRequest<Anagrams>(entityName: "Anagrams")
    }

    @NSManaged public var anagramId: Int32
    @NSManaged public var answerText: String?
    @NSManaged public var questionText: String?
    @NSManaged public var categories: NSSet?
    @NSManaged public var games: Games?

}

// MARK: Generated accessors for categories
extension Anagrams {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: Categories)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: Categories)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}
