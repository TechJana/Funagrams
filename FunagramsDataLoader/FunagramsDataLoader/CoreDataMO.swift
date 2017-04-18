//
//  CoreDataMO.swift
//  FunagramsDataLoader
//
//  Created by Saravanan ImmaMaheswaran on 4/8/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMO {
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.razeware.HitList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "FunagramModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let bundle = Bundle.main
        let databaseName = "FunagramModel"
        let databaseNameWithExtension = "\(databaseName).sqlite"
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(databaseNameWithExtension)
        print(url)
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [:])
        } catch let error1 as NSError {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error1
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func saveJson2Database () ->Void {
        let modeDict: NSMutableDictionary = NSMutableDictionary()
        let levelDict: NSMutableDictionary = NSMutableDictionary()
        let categoryDict: NSMutableDictionary = NSMutableDictionary()
        let anagramDict: NSMutableDictionary = NSMutableDictionary()
        let gamesDict: NSMutableDictionary = NSMutableDictionary()

        var error: NSError? = nil
        let dataPath = Bundle.main.path(forResource: "AnagramsData", ofType: "json")
        NSLog("JSON File: \"\(String(describing: dataPath))\"")
        let data = try? Data(contentsOf: URL(fileURLWithPath: dataPath!))
        do {
            let anagramsData: NSArray = (try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray)!
            
            NSLog("\(JSONSerialization.isValidJSONObject(anagramsData))")
            //NSLog("Imported Thirukkural data: \(anagramsData)")
            //println(anagramsData[0]["modesModeId"])
            for anagram in (anagramsData as NSArray) {
                let thisAnagram = (anagram as! NSDictionary)
                var modes: Modes
                var levels: Levels
                var categories: Categories
                var anagrams: Anagrams
                var games: Games

                // add modes only if it doesn't exist in our dictionary
                if let modeKey = modeDict[String(thisAnagram["modesModeId"] as! Int32)] {
                    modes = modeKey as! Modes
                    print("skipping modes addition")
                }
                else {
                    modes = NSEntityDescription.insertNewObject(forEntityName: "Modes", into: managedObjectContext!) as! Modes
                    modes.modeId = thisAnagram["modesModeId"] as! Int32
                    modes.modeDescription = thisAnagram["modesModeDescription"] as? String
                    modes.hintsPercentile = thisAnagram["modesHintsPercentile"] as! Float
                    
                    modeDict.setValue(modes, forKey: String(modes.modeId))
                }
                
                // add levels only if it doesn't exist in our dictionary
                if let levelKey = levelDict[String(thisAnagram["levelsLevelId"] as! Int32)] {
                    levels = levelKey as! Levels
                    print("skipping levels addition")
                }
                else {
                    levels = NSEntityDescription.insertNewObject(forEntityName: "Levels", into: managedObjectContext!) as! Levels
                    levels.levelId = thisAnagram["levelsLevelId"] as! Int32
                    levels.levelDescription = thisAnagram["levelsLevelDescription"] as? String
                    
                    levelDict.setValue(levels, forKey: String(levels.levelId))
                }
                
                // add categories only if it doesn't exist in our dictionary
                if let categoryKey = categoryDict[String(thisAnagram["categoriesCategoryId"] as! Int16)] {
                    categories = categoryKey as! Categories
                    print("skipping categories addition")
                }
                else {
                    categories = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: managedObjectContext!) as! Categories
                    categories.categoryId = thisAnagram["categoriesCategoryId"] as! Int16
                    categories.categoryDescription = thisAnagram["categoriesCategoryDescription"] as? String
                    
                    categoryDict.setValue(categories, forKey: String(categories.categoryId))
                }
                
                // add anagrams only if it doesn't exist in our dictionary
                if let anagramKey = anagramDict[String(thisAnagram["anagramsAnagramId"] as! Int32)] {
                    anagrams = anagramKey as! Anagrams
                    print("skipping anagrams addition")
                }
                else {
                    anagrams = NSEntityDescription.insertNewObject(forEntityName: "Anagrams", into: managedObjectContext!) as! Anagrams
                    anagrams.anagramId = thisAnagram["anagramsAnagramId"] as! Int32
                    anagrams.questionText = thisAnagram["anagramsQuestionText"] as? String
                    anagrams.answerText = thisAnagram["anagramsAnswerText"] as? String
                    
                    anagramDict.setValue(anagrams, forKey: String(anagrams.anagramId))
                }
                
                // add games only if it doesn't exist in our dictionary
                if let gameKey = gamesDict[String(thisAnagram["gamesGameId"] as! Int64)] {
                    games = gameKey as! Games
                    print("skipping games addition")
                }
                else {
                    games = NSEntityDescription.insertNewObject(forEntityName: "Games", into: managedObjectContext!) as! Games
                    games.gameId = thisAnagram["gamesGameId"] as! Int64
                    games.maxScore = thisAnagram["anagramsMaxScore"] as! Int32
                    
                    gamesDict.setValue(games, forKey: String(games.gameId))
                }
                
                modes.addToGames(games)
                
                levels.addToGames(games)
                
                categories.addToAnagrams(anagrams)
                
                anagrams.games = games
                anagrams.addToCategories(categories)
                
                games.anagram = anagrams
                games.level = levels
                games.mode = modes
            }
        } catch let error1 as NSError {
            error = error1
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
        }
        // save managedObjectContext here
        do {
            try managedObjectContext?.save()
        } catch let error1 as NSError {
            NSLog("Error while saving: \(error1)")
            exit(1)
        }
    }
}
