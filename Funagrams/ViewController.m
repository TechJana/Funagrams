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

@interface ViewController () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

@end

@implementation ViewController

@synthesize gameScoreBoard;
@synthesize buttonPlay;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    
    // Show something once when the application lauch after installation
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"Avalue"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"Avalue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Action here
        
    }
}

- (void)getInAppProducts
{
    _products = nil;
    [[InAppPurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
}

- (void)showInAppProducts
{
    // loop through all products and display
    for (int indexCount=0; indexCount<_products.count; indexCount++) {
        SKProduct *product = (SKProduct *) _products[indexCount];
        //textLabel.text = product.localizedTitle;
        [_priceFormatter setLocale:product.priceLocale];
        //detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
        
        if ([[InAppPurchase sharedInstance] productPurchased:product.productIdentifier]) {
            //accessoryType = UITableViewCellAccessoryCheckmark;
            //accessoryView = nil;
        } else {
            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
            buyButton.tag = indexCount;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            //accessoryType = UITableViewCellAccessoryNone;
            //accessoryView = buyButton;
        }
    }
}
    
- (IBAction) buttonPlay_click:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Mode" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet showFromToolbar:self.view];
}
    
- (IBAction) buttonBeginner_click:(id)sender
{
    
}
    
- (IBAction) buttonIntermediate_click:(id)sender
{
        
}

- (IBAction) buttonExpert_click:(id)sender
{
    
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
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
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
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
