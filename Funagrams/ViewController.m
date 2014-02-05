//
//  ViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ViewController.h"
//#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize gameScoreBoard;
/*
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;
@synthesize leaderboardHighScoreDescription;
@synthesize leaderboardHighScoreString;
@synthesize cachedHighestScore;
@synthesize currentScore;
@synthesize personalBestScoreDescription;
@synthesize personalBestScoreString;
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    scoreBoard = [[ScoreBoard alloc] init];
    gameScoreBoard = scoreBoard;
    
#if TEST_MODE_DEF
    scoreBoard.currentGameScore = 10;
#endif
   
    [[GCHelper defaultHelper] authenticateLocalUserOnViewController:self setCallbackObject:self withPauseSelector:@selector(authenticationRequired)];
    [[GCHelper defaultHelper] registerListener:self];
    
    /*
    if([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager= [[GameCenterManager alloc] init];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
	else
	{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Center Support Required!"
                                                        message:@"The current device does not support Game Center, which this sample requires."
                                                       delegate:nil
                                              cancelButtonTitle:@"dismiss"
                                              otherButtonTitles:nil];
        [alert show];
	}
     */

    
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


/*
 
 - (void) showAlertWithTitle: (NSString*) title message: (NSString*) message
 {
 UIAlertView* alert= [[UIAlertView alloc] initWithTitle: title message: message
 delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL];
 [alert show];
 
 }
 

#pragma mark GameCenter View Controllers
- (void) showLeaderboard;
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL)
	{
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
        [self presentViewController:leaderboardController animated:YES completion:nil];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
	//[viewController release];
}

- (void) showAchievements
{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
		[self presentViewController: achievements animated: YES completion:nil];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
{
	[self dismissViewControllerAnimated: YES completion:nil];
	//[viewController release];
}

- (IBAction) resetAchievements: (id) sender
{
	[gameCenterManager resetAchievements];
}


#pragma mark GameCenterDelegateProtocol Methods
//Delegate method used by processGameCenterAuth to support looping waiting for game center authorization
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.gameCenterManager authenticateLocalUser];
}

- (void) processGameCenterAuth: (NSError*) error
{
	if(error == NULL)
	{
		[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
	}
	else
	{
		UIAlertView* alert= [[UIAlertView alloc] initWithTitle: @"Game Center Account Required"
                                                        message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]
                                                       delegate: self cancelButtonTitle: @"Try Again..." otherButtonTitles: NULL];
		[alert show];
	}
	
}

- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;
{
	if((error == NULL) && (player != NULL))
	{
		self.leaderboardHighScoreDescription= [NSString stringWithFormat: @"%@ got:", player.alias];
		
		if(self.cachedHighestScore != NULL)
		{
			self.leaderboardHighScoreString= self.cachedHighestScore;
		}
		else
		{
			self.leaderboardHighScoreString= @"-";
		}
        
	}
	else
	{
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
	}
	//[self.tableView reloadData];
}

- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
{
	if(error == NULL)
	{
		int64_t personalBest= leaderBoard.localPlayerScore.value;
		self.personalBestScoreDescription= @"Your Best:";
		self.personalBestScoreString= [NSString stringWithFormat: @"%lld", personalBest];
		if([leaderBoard.scores count] >0)
		{
			self.leaderboardHighScoreDescription=  @"-";
			self.leaderboardHighScoreString=  @"";
			GKScore* allTime= [leaderBoard.scores objectAtIndex: 0];
			self.cachedHighestScore= allTime.formattedValue;
			[gameCenterManager mapPlayerIDtoPlayer: allTime.playerID];
		}
	}
	else
	{
		self.personalBestScoreDescription= @"GameCenter Scores Unavailable";
		self.personalBestScoreString=  @"-";
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
		//[self showAlertWithTitle: @"Score Reload Failed!"
		//				 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
	//[self.tableView reloadData];
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL)
	{
		[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
		[self showAlertWithTitle: @"High Score Reported!"
						 message: [NSString stringWithFormat: @"%@", [error localizedDescription]]];
	}
	else
	{
		[self showAlertWithTitle: @"Score Report Failed!"
						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}



- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
{
	if((error == NULL) && (ach != NULL))
	{
		if(ach.percentComplete == 100.0)
		{
			[self showAlertWithTitle: @"Achievement Earned!"
                             message: [NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]];
		}
		else
		{
			if(ach.percentComplete > 0)
			{
				[self showAlertWithTitle: @"Achievement Progress!"
                                 message: [NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]];
			}
		}
	}
	else
	{
		[self showAlertWithTitle: @"Achievement Submission Failed!"
                         message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}

- (void) achievementResetResult: (NSError*) error;
{
	self.currentScore= 0;
	//[self.tableView reloadData];
	if(error != NULL)
	{
		[self showAlertWithTitle: @"Achievement Reset Failed!"
                         message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
}
 */

@end
