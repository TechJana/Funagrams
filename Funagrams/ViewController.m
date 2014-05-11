//
//  ViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "InAppPurchase.h"
#import <StoreKit/StoreKit.h>
#import "GameViewController.h"
#import "AHAlertView.h"
#import "LevelHeaderViewController.h"
#import "Levels.h"

@interface ViewController ()
{
    NSNumberFormatter * _priceFormatter;
    NSManagedObjectContext *context;
}

@end

@implementation ViewController

@synthesize gameScoreBoard;
@synthesize buttonPlay;
@synthesize buttonMusic;
@synthesize buttonGameMode;
@synthesize buttonBeginner;
@synthesize buttonIntermediate;
@synthesize buttonExpert;
@synthesize popoverController;
@synthesize thisParentViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];

	// Do any additional setup after loading the view, typically from a nib.
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];

    [self reloadInputViews];
    
    scoreBoard = [[ScoreBoard alloc] init];
    gameScoreBoard = scoreBoard;
    
#if TEST_MODE_DEF
    scoreBoard.currentGameScore = 10;
#endif
    
    // Game center
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navController = (UINavigationController*)self.parentViewController;
    [[GCHelper defaultHelper] authenticateLocalUserOnViewController:self setCallbackObject:self withPauseSelector:@selector(authenticationRequired)];
    [[GCHelper defaultHelper] registerListener:self];
    
    // in app purchase
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    _inAppFetchCompleted = NO;
    [self getInAppProducts];
   
    // Show something once when the application lauch after installation
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"Avalue"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"Avalue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Action here
        
    }
}

- (IBAction) buttonFavorite_click:(id)sender
{
    AHAlertView *alert = [[AHAlertView alloc] initWithTitle:NSLocalizedString(@"FavoriteTitle", nil)
                                                    message:NSLocalizedString(@"FavoriteDescription", nil)];
    [alert setBackgroundImage:[UIImage imageNamed:@"AlertBackgroundImage"]];
    [alert setCancelButtonBackgroundImage:[[UIImage imageNamed:@"ButtonImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 45, 40, 45)] forState:UIControlStateNormal];
    [alert setButtonBackgroundImage:[[UIImage imageNamed:@"ButtonImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 45, 40, 45)] forState:UIControlStateNormal];
    [alert setCancelButtonTitle:NSLocalizedString(@"FavoriteCancelButtonTitle", nil) block:^{}];
    [alert addButtonWithTitle:NSLocalizedString(@"FavoriteRateButtonTitle", nil) block:^{[[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"iTunesReviewUrl", nil)]];}];
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
}

- (void) reloadInputViews
{
    // get the selection from Settings
    NSNumber *settingsGameMode = (NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:kSettingsGameMode];
    [self buttonGameModeSelection_click:[settingsGameMode intValue]];
    
    BOOL playMusic = (BOOL)[[NSUserDefaults standardUserDefaults] valueForKey:kSettingsMusic];
    if (playMusic)
    {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) playBackgroundMusic];
        [buttonMusic setImage:[UIImage imageNamed:@"MusicOnImage"] forState:UIControlStateNormal];
    }
    else
    {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) stopBackgroundMusic];
        [buttonMusic setImage:[UIImage imageNamed:@"MusicOffImage"] forState:UIControlStateNormal];
    }
    
}

- (IBAction) buttonGameModeSelection_click:(int)selectedMode
{
    UIImage *modeImage = nil;
    
    _gameMode = selectedMode;
    // set the selection in Settings
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selectedMode] forKey:kSettingsGameMode];
    
    switch (_gameMode) {
        case kGameModeBeginner:
            modeImage = [UIImage imageNamed:@"GameModeBeginnerImage"];
            break;
            
        case kGameModeIntermediate:
            modeImage = [UIImage imageNamed:@"GameModeIntermediateImage"];
            break;
            
        case kGameModeExpert:
            modeImage = [UIImage imageNamed:@"GameModeExpertImage"];
            break;
    }
    
    [buttonGameMode setImage:modeImage forState:UIControlStateNormal];
}

- (IBAction) buttonGameMode_click:(id)sender
{
    NSInteger numberOfOptions = 3;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"BeginnerImage"] title:@"" action:^{
                           [self buttonGameModeSelection_click:kGameModeBeginner];
                       }],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"IntermediateImage"] title:@"" action:^{
                           [self buttonGameModeSelection_click:kGameModeIntermediate];
                       }],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ExpertImage"] title:@"" action:^{
                           [self buttonGameModeSelection_click:kGameModeExpert];
                       }],
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.backgroundColor = [UIColor clearColor];
    av.highlightColor = [UIColor clearColor];
    av.singleLineView = YES;
    av.horizontalSpacing = 20;
    av.fixedImageSize = NO;
    av.delegate = self;
    
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (IBAction) buttonMusic_click:(id)sender
{
    if (((AppDelegate*)[[UIApplication sharedApplication] delegate]).isMusicPlaying)
    {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) stopBackgroundMusic];
        [buttonMusic setImage:[UIImage imageNamed:@"MusicOffImage"] forState:UIControlStateNormal];
    }
    else
    {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) playBackgroundMusic];
        [buttonMusic setImage:[UIImage imageNamed:@"MusicOnImage"] forState:UIControlStateNormal];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:(((AppDelegate*)[[UIApplication sharedApplication] delegate]).isMusicPlaying)] forKey:kSettingsMusic];
}

- (IBAction) buttonPlay_click:(id)sender
{
    //[self goToGameLevel:_gameMode level:kGameLevelLastIncompleteLevel];
    [self showLevelPopUp];
}

- (IBAction) buttonBuy_click:(id)sender
{
    [self getInAppProducts];
    [self showInAppProducts];
}

- (NSMutableArray *)getLevelsFromMode:(NSNumber*)numModeId
{
    NSMutableArray *menus = [[NSMutableArray alloc] init];
    NSEntityDescription *levelsEntity = [NSEntityDescription entityForName:@"Levels" inManagedObjectContext:context];
    NSFetchRequest *levelsFetchRequest = [[NSFetchRequest alloc] init];
    [levelsFetchRequest setEntity:levelsEntity];

    //NSPredicate *levelsPredicate = [NSPredicate predicateWithFormat:@"ANY games.mode.modeId == %@", numModeId];
    NSPredicate *levelsPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(games, $games, ANY $games.mode.modeId == %@).@count > 0", numModeId];
    [levelsFetchRequest setPredicate:levelsPredicate];
    
    NSError *error;
    
    NSArray *matchingLevelsforMode = [context executeFetchRequest:levelsFetchRequest error:&error];
    
    NSLog(@"ModeID: %@ - Levels for this mode: %lu ", numModeId,(unsigned long)matchingLevelsforMode.count);
    
    RNGridMenuItem *thisMenuItem = nil;
    UIImage *thisImage = nil;
    BOOL previousLevelLocked = YES;
    int previousLevelLockedCount = 0;
    NSSortDescriptor *sortHighScore = [NSSortDescriptor sortDescriptorWithKey:@"highScore" ascending:NO];
    for (int index=0; index<matchingLevelsforMode.count; index++)
    {
        Levels *thisLevel = (Levels*)[matchingLevelsforMode objectAtIndex:index];
        NSLog(@"Current Level ID : %@", thisLevel.levelId);
        BOOL canEnableLevel = NO;
        NSMutableArray *thisGames = nil, *thisScores = nil;
        Games *thisGame = nil;
        thisGames = [[thisLevel.games allObjects] mutableCopy];
        if (thisGames.count > 0) {
            //thisGame = [thisGames objectAtIndex:0];
            NSMutableOrderedSet *gamesSet = [NSMutableOrderedSet orderedSetWithSet:thisLevel.games];
            [gamesSet sortUsingDescriptors:@[sortHighScore]];
            thisGame = (Games *)[gamesSet objectAtIndex:0];
            thisScores = [[thisGame.score allObjects] mutableCopy];
        }
        
        if (thisScores != nil  &&  thisScores.count > 0)
        {
            canEnableLevel = YES;
            Scores *thisScore = [thisScores objectAtIndex:0];
            float percentile = [thisScore.score intValue]/[thisGame.maxScore intValue];
            if (percentile < 0.33)
            {
                thisImage = [UIImage imageNamed:@"LevelNoStarImage"];
            }
            else if (percentile < 0.66)
            {
                thisImage = [UIImage imageNamed:@"LevelOneStarImage"];
            }
            else if (percentile < 0.99)
            {
                thisImage = [UIImage imageNamed:@"LevelTwoStarImage"];
            }
            else
            {
                thisImage = [UIImage imageNamed:@"LevelThreeStarImage"];
            }
            previousLevelLocked = NO;
            canEnableLevel = YES;
        }
        else
        {
            if (previousLevelLocked  &&  index>0)
            {
                thisImage = [UIImage imageNamed:@"LevelLockImage"];
            }
            else
            {
                thisImage = [UIImage imageNamed:@"LevelNoStarImage"];
                previousLevelLocked = NO;
                canEnableLevel = YES;
                previousLevelLockedCount++;
            }
        }
        
        if (previousLevelLockedCount > 1)
        {
            previousLevelLocked = YES;
        }

        if (canEnableLevel)
        {
            thisMenuItem = [[RNGridMenuItem alloc] initWithImage:thisImage title:[NSString stringWithFormat:@"%d", [thisLevel.levelId intValue]] action:^{
                [self goToGameLevel:_gameMode level:[thisLevel.levelId intValue]];
            }];
        }
        else
        {
            thisMenuItem = [[RNGridMenuItem alloc] initWithImage:thisImage title:[NSString stringWithFormat:@"%d", [thisLevel.levelId intValue]] action:nil];
        }

        [menus addObject:thisMenuItem];
    }
    
    return menus;
}

- (void)showLevelPopUp
{
    NSArray *items = [[NSArray alloc] initWithArray:[self getLevelsFromMode:[NSNumber numberWithInt:_gameMode]]];
    
    // exit if we didn't find any level data
    if (items.count == 0)
        return;
    
    NSInteger numberOfOptions=items.count;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad  &&  numberOfOptions > 32)
    {
        numberOfOptions = 32;
    }
    else if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad  &&  numberOfOptions > 18)
    {
        numberOfOptions = 18;
    }

    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    
    LevelHeaderViewController *headerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"levelHeaderViewController"];
    [headerViewController.view setFrame:CGRectMake(0, 0, 275, 60)];
    [headerViewController.view setBackgroundColor:[UIColor clearColor]];
    switch (_gameMode)
    {
        case kGameModeBeginner:
            headerViewController.labelLevel.text = NSLocalizedString(@"GameModeBeginner", nil);
            break;
            
        case kGameModeIntermediate:
            headerViewController.labelLevel.text = NSLocalizedString(@"GameModeIntermediate", nil);
            break;
            
        case kGameModeExpert:
            headerViewController.labelLevel.text = NSLocalizedString(@"GameModeExpert", nil);
            break;
    }
    av.headerView = headerViewController.view;
    
    av.backgroundColor = [UIColor clearColor];
    av.highlightColor = [UIColor clearColor];
    av.horizontalSpacing = -40;
    av.verticalSpacing = -40;
    av.fixedImageSize = NO;
    av.menuColumnsCount = 6;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        av.menuColumnsCount = 8;
    }
    av.itemTextAlignment = NSTextAlignmentCenter;
    av.textOnImage = YES;
    av.itemTextVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    av.itemTextColor = [UIColor yellowColor];
    av.itemTextShadowColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:0.8];
    av.itemFont = [UIFont systemFontOfSize:30.0];
    av.doNotDismissIfNoAction = YES;
    //av.itemSize = CGSizeMake(39, 38);
    av.delegate = self;
    
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %d: %@", itemIndex, item.title);
}

- (void)goToGameLevel:(int)mode level:(int)level
{
    GameViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameViewController"];
    myController.currentGameMode = mode;
    myController.currentGameLevel = level;
    [self.navigationController pushViewController:myController animated:YES];
}

#pragma mark - InApp
- (void)getInAppProducts
{
    _inAppProdcuts = nil;
    [[InAppPurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _inAppProdcuts = products;
        }
        _inAppFetchCompleted = YES;
    }];
}

- (void)showInAppProducts
{
    NSMutableArray *items = [[NSMutableArray alloc] init];

    // loop through all products and display
    for (int indexCount=0; indexCount<_inAppProdcuts.count; indexCount++) {
        SKProduct *product = (SKProduct *) _inAppProdcuts[indexCount];
        [_priceFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [_priceFormatter stringFromNumber:product.price];
        NSString *imageName = [NSString stringWithFormat:@"%@Image", product.productIdentifier];
        RNGridMenuItem *menuItem;

        if ([[InAppPurchase sharedInstance] productPurchased:product.productIdentifier])
        {
            formattedPrice = [_priceFormatter stringFromNumber:[NSNumber numberWithFloat:0.00]];
            menuItem = [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:[NSString stringWithFormat:@"%@ (%@)", product.localizedTitle, formattedPrice] action:nil];
        } else
        {
            menuItem = [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:imageName] title:[NSString stringWithFormat:@"%@ (%@)", product.localizedTitle, formattedPrice] action:^{
                [self buyProductAtIndex:indexCount];
            }];
        }
        [items addObject:menuItem];
    }
    NSInteger numberOfOptions = items.count;
    
    RNGridMenu *inAppMenu = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    inAppMenu.backgroundColor = [UIColor clearColor];
    inAppMenu.highlightColor = [UIColor clearColor];
    inAppMenu.singleLineView = YES;
    inAppMenu.horizontalSpacing = 20;
    inAppMenu.fixedImageSize = NO;
    inAppMenu.delegate = self;
    
    [inAppMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)buyProductAtIndex:(int)sender
{
    SKProduct *product = _inAppProdcuts[sender];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[InAppPurchase sharedInstance] buyProduct:product];
}

- (void)restoreTapped:(id)sender {
    [[InAppPurchase sharedInstance] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_inAppProdcuts enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            _inAppPurchasedProductIndex = (int)idx;
            *stop = YES;
        }
        _inAppProductPurchaseComplete = YES;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)authenticationRequired
{
    //if the game is open, it should be paused
    /*AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.gameScene)
    {
        [appDelegate.gameScene pauseGame];
    }*/
}

- (IBAction)showAchievement:(id)sender {
    [[GCHelper defaultHelper] showAchievementsOnViewController:self];
}

- (IBAction)showLeaderboard:(id)sender {
    [[GCHelper defaultHelper] showLeaderboardOnViewController:self];
}

- (IBAction)resetAchievements:(id)sender {
    [[GCHelper defaultHelper] resetAchievements];
}

// called when you complete a challenge sent by a friend
- (void)player:(GKPlayer *)player didCompleteChallenge:(GKChallenge *)challenge issuedByFriend:(GKPlayer *)friendPlayer
{
    UIAlertView *completedChallenge = [[UIAlertView alloc] initWithTitle:@"Challenge completed" message:@"Congratulations!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [completedChallenge show];
}

// called when a friend completed a challenge issued by you
- (void)player:(GKPlayer *)player issuedChallengeWasCompleted:(GKChallenge *)challenge byFriend:(GKPlayer *)friendPlayer
{
    NSMutableString *friend = [[NSMutableString alloc] initWithString:@"Your friend "];
    [friend appendString:[friendPlayer displayName]];
    [friend appendString:@" has successfully completed the challenge!"];
    UIAlertView *completedChallenge = [[UIAlertView alloc] initWithTitle:@"Challenge completed" message:friend delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [completedChallenge show];
}

// called when you click on the challenge notification, while not playing the game
- (void)player:(GKPlayer *)player wantsToPlayChallenge:(GKChallenge *)challenge
{
    [self performSegueWithIdentifier:@"startPlaying" sender:self];
}

// called when you received a challenge while playing the game
- (void)player:(GKPlayer *)player didReceiveChallenge:(GKChallenge *)challenge
{
    NSMutableString *friend = [[NSMutableString alloc] initWithString:@"Your friend "];
    [friend appendString:[player displayName]];
    [friend appendString:@" has invited you to complete a challenge:\n"];
    [friend appendString:[challenge message]];
    UIAlertView *theChallenge = [[UIAlertView alloc] initWithTitle:@"Want to take the challenge?" message:friend delegate:self cancelButtonTitle:@"Challenge accepted" otherButtonTitles:@"No", nil];
    [theChallenge show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self performSegueWithIdentifier:@"startPlaying" sender:self];
    }
}

@end
