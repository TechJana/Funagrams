//
//  main.m
//  CoreDatabaseEditor
//
//  Created by Saravanan ImmaMaheswaran on 2/23/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "Categories.h"
#import "Modes.h"
#import "Levels.h"
#import "Anagrams.h"
#import "Games.h"
#import "Scores.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"FunagramModel";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSError *error;
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingLastPathComponent];
        path = [path stringByAppendingPathComponent:@"Funagrams"];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        NSLog(@"File path:'%@'", url);
        
        NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
        [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, pragmaOptions, NSSQLitePragmasOption, nil];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:options error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

static void saveDataToDatabase()
{
    
    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        NSError* err = nil;
        int indexAnagram;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AnagramsData" ofType:@"json"];
        NSArray* AnagramsData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                                options:kNilOptions
                                                                  error:&err];
        NSLog(@"Imported Anagrams: %@", AnagramsData);
        
        NSMutableDictionary *dataModes = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *dataLevels = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *dataCategories = [[NSMutableDictionary alloc] init];
        BOOL modeExists, levelExists, categoryExists;
        Modes *modes;
        Levels *levels;
        Categories *categories;
        Anagrams *anagrams;
        Games *games;
        
        for (indexAnagram=0; indexAnagram<AnagramsData.count; indexAnagram++)
        {
            id obj = [AnagramsData objectAtIndex:indexAnagram];
            
            // Modes
            if ([dataModes objectForKey:[obj objectForKey:@"modesModeId"]] != nil) {
                modes = (Modes *)[dataModes objectForKey:[obj objectForKey:@"modesModeId"]];
                modeExists = TRUE;
            }
            else {
                modes = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Modes"
                         inManagedObjectContext:context];
                modeExists = FALSE;
            }
            
            // Levels
            if ([dataLevels objectForKey:[obj objectForKey:@"levelsLevelId"]] != nil) {
                levels = (Levels *)[dataLevels objectForKey:[obj objectForKey:@"levelsLevelId"]];
                levelExists = TRUE;
            }
            else {
                levels = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Levels"
                          inManagedObjectContext:context];
                levelExists = FALSE;
            }
            
            // Categories
            if ([dataCategories objectForKey:[obj objectForKey:@"categoriesCategoryId"]] != nil) {
                categories = (Categories *)[dataCategories objectForKey:[obj objectForKey:@"categoriesCategoryId"]];
                categoryExists = TRUE;
            }
            else {
                categories = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Categories"
                              inManagedObjectContext:context];
                categoryExists = FALSE;
            }
            anagrams = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Anagrams"
                        inManagedObjectContext:context];
            games = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Games"
                     inManagedObjectContext:context];
            
            modes.modeId = [obj objectForKey:@"modesModeId"];
            modes.modeDescription = [obj objectForKey:@"modesModeDescription"];
            modes.hintsPercentile = [obj objectForKey:@"modesHintsPercentile"];
            
            levels.levelId = [obj objectForKey:@"levelsLevelId"];
            levels.levelDescription = [obj objectForKey:@"levelsLevelDescription"];
            
            categories.categoryId = [obj objectForKey:@"categoriesCategoryId"];
            categories.categoryDescription = [obj objectForKey:@"categoriesCategoryDescription"];
            
            anagrams.anagramId = [obj objectForKey:@"anagramsAnagramId"];
            anagrams.questionText = [obj objectForKey:@"anagramsQuestionText"];
            anagrams.answerText = [obj objectForKey:@"anagramsAnswerText"];
            
            games.gameId = [obj objectForKey:@"gamesGameId"];
            games.maxScore = [obj objectForKey:@"anagramsMaxScore"];
            
            [modes addGamesObject:games];
            [levels addGamesObject:games];
            anagrams.games = games;
            [anagrams addCategoriesObject:categories];
            [categories addAnagramsObject:anagrams];
            
            games.mode = modes;
            games.level = levels;
            games.anagram = anagrams;
            games.score = nil;
            
            if (!modeExists) {
                [dataModes setObject:modes forKey:[obj objectForKey:@"modesModeId"]];
            }
            
            if (!levelExists) {
                [dataLevels setObject:levels forKey:[obj objectForKey:@"levelsLevelId"]];
            }
            
            if (!categoryExists) {
                [dataCategories setObject:categories forKey:[obj objectForKey:@"categoriesCategoryId"]];
            }
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        // Test listing all FailedBankInfos from the store
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Games"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (Games *game in fetchedObjects) {
            NSLog(@"Name: %@", game);
        }
    }
}

static void readDataFromDatabase()
{
    
    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Games" inManagedObjectContext:context];
        NSFetchRequest *gamesFetchRequest = [[NSFetchRequest alloc] init];
        [gamesFetchRequest setEntity:gamesEntity];
        
        NSArray *matchingGames = [context executeFetchRequest:gamesFetchRequest error:&error];
        
        NSLog(@"Games count: %lu ", (unsigned long)matchingGames.count);
        
        for (int index=0; index<matchingGames.count; index++)
        {
            NSInteger randomGameId = arc4random()% (matchingGames.count + 0);
            //currentGamesFromModel = [NSEntityDescription insertNewObjectForEntityForName:@"Games" inManagedObjectContext:context];
            
            Games *currentGames = (Games*)[matchingGames objectAtIndex:randomGameId];
            //NSLog(@"Current Game ID : %@", currentGames.gameId);
            NSArray *categoryArray = [currentGames.anagram.categories allObjects];
            Categories *category;
            if (categoryArray.count > 0)
            {
                category = (Categories *)[categoryArray objectAtIndex:0];
                NSLog(@"gameId-%@, modeId-%@, levelId-%@, categoryId-%@, anagramId-%@, question-%@, answer-%@", currentGames.gameId, currentGames.mode.modeId, currentGames.level.levelId, category.categoryId, currentGames.anagram.anagramId, currentGames.anagram.questionText, currentGames.anagram.answerText);
            }
            else
            {
                NSLog(@"gameId-%@, modeId-%@, levelId-%@, anagramId-%@, question-%@, answer-%@", currentGames.gameId, currentGames.mode.modeId, currentGames.level.levelId, currentGames.anagram.anagramId, currentGames.anagram.questionText, currentGames.anagram.answerText);
            }
        }
    }
}

int main(int argc, const char * argv[])
{
    readDataFromDatabase();
    //saveDataToDatabase();
    
    return 0;
}

