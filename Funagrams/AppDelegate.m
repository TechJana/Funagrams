//
//  AppDelegate.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "AppDelegate.h"
#import "InAppPurchase.h"
#import "Levels.h"
#import "Modes.h"
#import "Anagrams.h"
#import "Games.h"
#import "Scores.h"
#import "Categories.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [InAppPurchase sharedInstance];
    [self playBackgroundMusic];
    
    // Core Data Model
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;

#if TEST_MODE_DEF_1
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
    Scores *scores = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Scores"
                              inManagedObjectContext:context];

    modes.modeId = [NSNumber numberWithInt:1];
    modes.modeDescription = @"Beginner";
    modes.hintsPercentile = [NSNumber numberWithFloat:0.9];
    
    levels.levelId = [NSNumber numberWithInt:1];
    levels.levelDescription = @"Level 1";

    categories.categoryId = [NSNumber numberWithInt:1];
    categories.categoryDescription = @"General";
    
    anagrams.anagramId = [NSNumber numberWithInt:1];
    anagrams.questionText = @"DORMITORY";
    anagrams.answerText = @"DIRTY ROOM";

    games.gameId = [NSNumber numberWithInt:1];
    games.modeId = [NSNumber numberWithInt:1];
    games.levelId = [NSNumber numberWithInt:1];
    games.anagramId = [NSNumber numberWithInt:1];
    games.maxScore = [NSNumber numberWithInt:1000];

    scores.scoreId = [NSNumber numberWithInt:1];
    scores.gameId = [NSNumber numberWithInt:1];
    scores.score = [NSNumber numberWithInt:500];

    modes.games = games;
    levels.games = games;
    anagrams.games = games;
    scores.game = games;
    [anagrams addCategoriesObject:categories];
    
    games.mode = modes;
    games.level = levels;
    games.anagram = anagrams;
    games.score = scores;
    
    if (![context save:&error])
    {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
#endif
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Games" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
#if TEST_MODE_DEF
    for (Games *game in fetchedObjects) {
        NSLog(@"Game Id: %@", game.gameId);
        NSLog(@"Mode Id: %@", game.mode);
        NSLog(@"Level Id: %@", game.levelId);
        NSLog(@"Anagram Id: %@", game.anagram);
        NSLog(@"Max Score: %@", game.maxScore);
        NSLog(@"Mode: %@", game.mode);
        NSLog(@"Level: %@", game.level);
        NSLog(@"Anagram: %@", game.anagram);
        NSLog(@"Score: %@", game.score);
    }
#endif
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)playBackgroundMusic
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"BackgroundMusicFileName", nil) ofType:NSLocalizedString(@"BackgroundMusicFileType", nil)];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = -1; //infinite
    //player.volume = 100;
    
    [player play];
}


//1
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

//2
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

//3
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Funagrams.sqlite"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]]) {
        NSURL *targetUrl = [storeUrl URLByDeletingPathExtension];
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Funagrams" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:[targetUrl URLByAppendingPathExtension:@"sqlite"] error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
        
        preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Funagrams" ofType:@"sqlite-shm"]];
        err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:[targetUrl URLByAppendingPathExtension:@"sqlite-shm"] error:&err]) {
            NSLog(@"Oops, could copy preloaded sqlite-shm file");
        }
        
        preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Funagrams" ofType:@"sqlite-wal"]];
        err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:[targetUrl URLByAppendingPathExtension:@"sqlite-wal"] error:&err]) {
            NSLog(@"Oops, could copy preloaded sqlite-wal file");
        }
    }
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
