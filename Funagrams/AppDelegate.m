//
//  AppDelegate.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "AppDelegate.h"
#import "InAppPurchase.h"

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
#if TEST_MODE_DEF
   NSManagedObject *levels = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Levels"
                               inManagedObjectContext:context];
    NSManagedObject *anagrams = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Anagrams"
                                 inManagedObjectContext:context];
    NSManagedObject *modes = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Modes"
                              inManagedObjectContext:context];
    NSManagedObject *games = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Games"
                              inManagedObjectContext:context];
    NSManagedObject *scores = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Scores"
                              inManagedObjectContext:context];

    [levels setValue:[NSNumber numberWithInt:1] forKey:@"levelId"];
    [levels setValue:@"Level 1" forKey:@"levelDescription"];

    [modes setValue:[NSNumber numberWithInt:1] forKey:@"modeId"];
    [modes setValue:@"Beginner" forKey:@"modeDescription"];
    [modes setValue:[NSNumber numberWithFloat:0.90] forKey:@"hintsPercentile"];

    [anagrams setValue:[NSNumber numberWithInt:1] forKey:@"anagramId"];
    [anagrams setValue:@"DORMITORY" forKey:@"questionText"];
    [anagrams setValue:@"DIRTY ROOM" forKey:@"answerText"];

    [games setValue:[NSNumber numberWithInt:1] forKey:@"gameId"];
    [games setValue:[NSNumber numberWithInt:1] forKey:@"modeId"];
    [games setValue:[NSNumber numberWithInt:1] forKey:@"levelId"];
    [games setValue:[NSNumber numberWithInt:1] forKey:@"anagramId"];
    [games setValue:[NSNumber numberWithInt:1000] forKey:@"maxScore"];

    [scores setValue:[NSNumber numberWithInt:1] forKey:@"scoreId"];
    [scores setValue:[NSNumber numberWithInt:1] forKey:@"gameId"];
    [scores setValue:[NSNumber numberWithInt:1] forKey:@"score"];

    [modes setValue:games forKey:@"games"];
    [levels setValue:games forKey:@"games"];
    [anagrams setValue:games forKey:@"games"];
    [scores setValue:games forKey:@"game"];

    [games setValue:modes forKey:@"mode"];
    [games setValue:levels forKey:@"level"];
    [games setValue:anagrams forKey:@"anagram"];
    [games setValue:scores forKey:@"score"];
    
    NSError *error;
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
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Game Id: %@", [info valueForKey:@"gameId"]);
        NSLog(@"Mode Id: %@", [info valueForKey:@"modeId"]);
        NSLog(@"Level Id: %@", [info valueForKey:@"levelId"]);
        NSLog(@"Anagram Id: %@", [info valueForKey:@"anagramId"]);
        NSLog(@"Max Score Id: %@", [info valueForKey:@"maxScore"]);
        NSManagedObject *details = [info valueForKey:@"mode"];
        NSLog(@"Mode Description: %@", [details valueForKey:@"modeDescription"]);
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
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
