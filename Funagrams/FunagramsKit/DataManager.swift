//
//  DataManager.swift
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/22/17.
//  Copyright © 2017 pluggablez. All rights reserved.
//

import CoreData

public class DataManager: NSObject {
    public class func getContext() -> NSManagedObjectContext {
        return FunagramsKit.sharedInstance.managedObjectContext!
    }
    
    public class func deleteManagedObject(object:NSManagedObject) {
        getContext().delete(object)
        saveManagedContext()
    }
    
    public class func saveManagedContext() {
        var error : NSError? = nil
        do {
            try getContext().save()
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error saving context \(String(describing: error)), \(error!.userInfo)")
            abort()
        }
    }
    
    public class func getNextGame(skill: Skill, anagramMaxLength: Int) -> (games: Games?, gamesPlayedSoFar: Int) {
        var games: Games?
        
        var levelsNotPlayed: String = ""
        var levelNotPlayed: [Int32] = []
        
        // fetch all Games which is not yet played
        let managedContext = DataManager.getContext()
        let fetchRequest: NSFetchRequest<Games> = NSFetchRequest(entityName:"Games")
        var predicate = NSPredicate(format: "mode.modeId = %d AND score.@count > 0", skill.rawValue)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults: [Games] = try managedContext.fetch(fetchRequest)
            // collect all levels for those games which were not played yet
            for index in 0..<fetchedResults.count {
                levelsNotPlayed += "\(fetchedResults[index].level!.levelId), "
                levelNotPlayed.append(fetchedResults[index].level!.levelId)
            }
            
            // trim the last comma
            if levelsNotPlayed.characters.count > 0 {
                let strIndex = levelsNotPlayed.index(levelsNotPlayed.startIndex, offsetBy: levelsNotPlayed.characters.count-2)
                levelsNotPlayed = levelsNotPlayed.substring(to: strIndex)
            }
        } catch {
            
        }
        
        if levelsNotPlayed.characters.count > 0 {
            // expecting at least one level from the list
            // fetch games excluding levels played
            predicate = NSPredicate(format: "mode.modeId = %d AND ANY score = nil AND NOT level.levelId IN %@ AND anagram.questionText MATCHES %@ AND anagram.answerText MATCHES %@ AND ANY score = nil", skill.rawValue, levelNotPlayed, String(format: ".{%d,%d}", 0, anagramMaxLength), String(format: ".{%d,%d}", 0, anagramMaxLength))
        }
        else {
            // fetch games - level exclusion doesn't apply
            predicate = NSPredicate(format: "mode.modeId = %d AND ANY score = nil AND anagram.questionText MATCHES %@ AND anagram.answerText MATCHES %@ AND ANY score = nil", skill.rawValue, String(format: ".{%d,%d}", 0, anagramMaxLength), String(format: ".{%d,%d}", 0, anagramMaxLength))
        }
        fetchRequest.predicate = predicate
        
        // sort order of ascending on level
        let sortDescriptor = NSSortDescriptor(key: "level.levelId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            
            if fetchedResults.count > 0 {
                let minLevelId = fetchedResults[0].level?.levelId
                let filteredFetchedResults = fetchedResults.filter({ (thisGames) -> Bool in
                    return (thisGames.level?.levelId == minLevelId)
                })
                games = filteredFetchedResults[Int(arc4random_uniform(UInt32(filteredFetchedResults.count-1)))]
            }
        } catch {
            // not sure what to do here
        }
        
        return (games, levelNotPlayed.count)
    }
    
    public class func getLastIncompleteLevel(skill: Skill) -> Level? {
        var level: Level?
        
        // fetch Games data
        let managedContext = DataManager.getContext()
        let fetchRequest: NSFetchRequest<Games> = NSFetchRequest(entityName:"Games")
        
        // get all incomplete level for the skill with sort order of ascending on level - we are looking for the top 1 only
        let predicate = NSPredicate(format: "mode.modeId = %d AND ANY score = nil", skill.rawValue)
        fetchRequest.predicate = predicate
        
        // sort order of ascending on level
        let sortDescriptor = NSSortDescriptor(key: "level.levelId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // looking for the top 1 only
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            
            if fetchedResults.count > 0 {
                level = Level(rawValue: Int((fetchedResults[0].level?.levelId)!))
            }
            else {
                level = Level.Level01
            }
        } catch let error as NSError {
            // not sure what to do here
            print(error)
        }
        
        return level
    }
    
    /**
     Update score for the game.
     - parameters:
        - gameId: game to be updated with the score
        - score: for the game
     */
    public class func updateScore(gameId: Int64, score: Int32) {
        var nextScoreId: Int64 = 1
        var game: Games!
        
        // fetch max score id
        let managedContext = DataManager.getContext()
        let fetchScoreRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"Scores")
        fetchScoreRequest.resultType = .dictionaryResultType
        let maxExpression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "scoreId")])
        let maxExpressionDescription = NSExpressionDescription()
        maxExpressionDescription.name = "maxScoreId"
        maxExpressionDescription.expression = maxExpression
        maxExpressionDescription.expressionResultType = .integer64AttributeType
        fetchScoreRequest.propertiesToFetch = [maxExpressionDescription]
        do {
            if let result = try managedContext.fetch(fetchScoreRequest) as? [[String: Int64]], let dict = result.first {
                nextScoreId = dict[maxExpressionDescription.name]! + 1  // increment max score id to create a new score
            }
        } catch {
            assertionFailure("Failed to fetch max score id with error = \(error)")
        }
        
        // fetch Games data
        let fetchRequest: NSFetchRequest<Games> = NSFetchRequest(entityName:"Games")
        let predicate = NSPredicate(format: "gameId = %d", gameId)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            game = fetchedResults[0] 
            let scores = NSEntityDescription.insertNewObject(forEntityName: "Scores", into: managedContext) as! Scores
            scores.scoreId = nextScoreId
            scores.score = score
            scores.playedOn = NSDate()
            scores.game = game
            
            game.addToScore(scores) // associate score to game
            
            DataManager.saveManagedContext()    // save to db
        } catch {
            // not sure what to do here
        }
    }
}
