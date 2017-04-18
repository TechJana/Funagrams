//
//  Categories+CoreDataProperties.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var categoryDescription: String?
    @NSManaged public var categoryId: Int16
    @NSManaged public var anagrams: NSSet?

}

// MARK: Generated accessors for anagrams
extension Categories {

    @objc(addAnagramsObject:)
    @NSManaged public func addToAnagrams(_ value: Anagrams)

    @objc(removeAnagramsObject:)
    @NSManaged public func removeFromAnagrams(_ value: Anagrams)

    @objc(addAnagrams:)
    @NSManaged public func addToAnagrams(_ values: NSSet)

    @objc(removeAnagrams:)
    @NSManaged public func removeFromAnagrams(_ values: NSSet)

}
