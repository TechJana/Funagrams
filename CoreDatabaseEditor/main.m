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

int main(int argc, const char * argv[])
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
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"AnagramsData" ofType:@"json"];
        NSArray* AnagramsData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                                options:kNilOptions
                                                                  error:&err];
        NSLog(@"Imported Banks: %@", AnagramsData);
        
        [AnagramsData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Modes *modes = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Modes"
                            inManagedObjectContext:context];
            Levels *levels = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Levels"
                              inManagedObjectContext:context];
            Categories *categories = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Categories"
                                      inManagedObjectContext:context];
            Anagrams *anagrams = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Anagrams"
                                  inManagedObjectContext:context];
            Games *games = [NSEntityDescription
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
            games.modeId = [obj objectForKey:@"gamesModeId"];
            games.levelId = [obj objectForKey:@"gamesLevelId"];
            games.anagramId = [obj objectForKey:@"anagramsAnagramsId"];
            games.maxScore = [obj objectForKey:@"anagramsMaxScore"];
            
            modes.games = games;
            levels.games = games;
            anagrams.games = games;
            [anagrams addCategoriesObject:categories];
            
            games.mode = modes;
            games.level = levels;
            games.anagram = anagrams;
            games.score = nil;

            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }];
        
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
    return 0;
}

