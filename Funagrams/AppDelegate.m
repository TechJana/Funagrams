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
#import "GlobalConstants.h"
#import "ViewController.h"
#import "AHAlertView.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (kLeaderBoardLevels == nil) {
        kLeaderBoardLevels = [[NSMutableArray alloc] initWithObjects:@"", kLeaderBoardLevel01, kLeaderBoardLevel02, kLeaderBoardLevel03, kLeaderBoardLevel04, kLeaderBoardLevel05, kLeaderBoardLevel06, kLeaderBoardLevel07, kLeaderBoardLevel08, kLeaderBoardLevel09, kLeaderBoardLevel10, kLeaderBoardLevel11, kLeaderBoardLevel12, kLeaderBoardLevel13, kLeaderBoardLevel14, kLeaderBoardLevel15, kLeaderBoardLevel16, kLeaderBoardLevel17, kLeaderBoardLevel18, kLeaderBoardLevel19, kLeaderBoardLevel20, nil];
    }
    
    [InAppPurchase sharedInstance];
    BOOL playMusic = (BOOL)[[NSUserDefaults standardUserDefaults] valueForKey:kSettingsMusic];
    if (playMusic) {
        [self playBackgroundMusic];
    }
    
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

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Games" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

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
    AHAlertView *alert = [AHAlertView alloc];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    int usageCount=[[userDefaults objectForKey:@"usageCount"]intValue];
    NSLog(@"Usage Count: %d",usageCount);
    switch (usageCount)
    {
        case 5:
        case 10:
        case 20:
        case 35:
            alert = [alert initWithTitle:NSLocalizedString(@"FavoriteTitle", nil)
                                                            message:NSLocalizedString(@"FavoriteDescription", nil)];
            [alert setBackgroundImage:[UIImage imageNamed:@"AlertBackgroundImage"]];
            [alert setCancelButtonBackgroundImage:[[UIImage imageNamed:@"ButtonImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 45, 40, 45)] forState:UIControlStateNormal];
            [alert setButtonBackgroundImage:[[UIImage imageNamed:@"ButtonImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 45, 40, 45)] forState:UIControlStateNormal];
            [alert setCancelButtonTitle:NSLocalizedString(@"FavoriteCancelButtonTitle", nil) block:^{}];
            [alert addButtonWithTitle:NSLocalizedString(@"FavoriteRateButtonTitle", nil) block:^{[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"iTunesReviewUrl", nil)]];}];
            [alert addButtonWithTitle:NSLocalizedString(@"FavoriteRemindMeButtonTitle", nil) block:^{}];
            //[alert setContentInsets:UIEdgeInsetsMake(12, 18, 12, 18)];
            
            [alert setButtonTitleTextAttributes:[AHAlertView textAttributesWithFont:[UIFont boldSystemFontOfSize:16]
                                                                    foregroundColor:[UIColor colorWithRed:43.0/255.0 green:30.0/255.0 blue:14.0/255.0 alpha:1.0]
                                                                        shadowColor:[UIColor grayColor]
                                                                       shadowOffset:CGSizeMake(0, -1)]];
            alert.dismissalStyle = AHAlertViewDismissalStyleZoomDown;
            // border radius
            [alert.layer setCornerRadius:15.0f];
            alert.layer.masksToBounds = YES;
            // border
            [alert.layer setBorderColor:[UIColor colorWithRed:28.0/255.0 green:41.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor];
            [alert.layer setBorderWidth:1.0f];
            [alert show];
            break;
    }
    [userDefaults setInteger:usageCount+1 forKey:@"usageCount"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIViewController* root = _window.rootViewController;
    UINavigationController* navController = (UINavigationController*)root;
    ViewController * mycontroller = (ViewController *)[[navController viewControllers] objectAtIndex:0];
    [mycontroller reloadInputViews];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)playBackgroundMusic
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"MusicBackgroundFileName", nil) ofType:NSLocalizedString(@"AudioFileTypeMP3", nil)];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = -1; //infinite
    //player.volume = 100;
    
    [player play];
    _isMusicPlaying = YES;
}

- (void)stopBackgroundMusic
{
    [player stop];
    _isMusicPlaying = NO;
}

- (void)playSoundFile:(NSString*)fileNameWithoutExtension
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:fileNameWithoutExtension ofType:NSLocalizedString(@"AudioFileTypeMP3", nil)];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    soundPlayer.numberOfLoops = 0; //play once
    
    [soundPlayer play];
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
        /*
        preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Funagrams" ofType:@"sqlite-shm"]];
        err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:[targetUrl URLByAppendingPathExtension:@"sqlite-shm"] error:&err]) {
            NSLog(@"Oops, could copy preloaded sqlite-shm file");
        }
        
        preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Funagrams" ofType:@"sqlite-wal"]];
        err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:[targetUrl URLByAppendingPathExtension:@"sqlite-wal"] error:&err]) {
            NSLog(@"Oops, could copy preloaded sqlite-wal file");
        }*/
    }
    
    NSError *error = nil;
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"DELETE" forKey:@"journal_mode"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, pragmaOptions, NSSQLitePragmasOption, nil];
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
