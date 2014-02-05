//
//  ViewController.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreBoard.h"
#import <GameKit/GameKit.h>
#import "GCHelper.h"
//#import "GameCenterManager.h"

@interface ViewController : UIViewController <GKLocalPlayerListener, UIAlertViewDelegate>/*<UIActionSheetDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate>*/
{
    ScoreBoard *scoreBoard;
    /*
	GameCenterManager* gameCenterManager;
	
    NSString* currentLeaderBoard;
	NSString* leaderboardHighScoreDescription;
	NSString* leaderboardHighScoreString;
	int64_t  currentScore;
	NSString* cachedHighestScore;
	NSString* personalBestScoreDescription;
	NSString* personalBestScoreString;
     */
}

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;
/*
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic, retain) NSString* leaderboardHighScoreDescription;
@property (nonatomic, retain) NSString* leaderboardHighScoreString;
@property (nonatomic, assign) int64_t currentScore;
@property (nonatomic, retain) NSString* cachedHighestScore;
@property (nonatomic, retain) NSString* personalBestScoreDescription;
@property (nonatomic, retain) NSString* personalBestScoreString;
 */

@end
