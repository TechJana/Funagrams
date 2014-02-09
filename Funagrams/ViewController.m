//
//  ViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize gameScoreBoard;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    scoreBoard = [[ScoreBoard alloc] init];
    gameScoreBoard = scoreBoard;
    
#if TEST_MODE_DEF
    scoreBoard.currentGameScore = 10;
#endif
   
    ((AppDelegate*)[[UIApplication sharedApplication] delegate]).navController = (UINavigationController*)self.parentViewController;
    [[GCHelper defaultHelper] authenticateLocalUserOnViewController:self setCallbackObject:self withPauseSelector:@selector(authenticationRequired)];
    [[GCHelper defaultHelper] registerListener:self];
    
    // Show something once when the application lauch
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"Avalue"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"Avalue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Action here
        
    }
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
