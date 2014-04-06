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
#import "RNGridMenu.h"
#import "GlobalConstants.h"

@interface ViewController : UIViewController <GKLocalPlayerListener, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, RNGridMenuDelegate>
{
    ScoreBoard *scoreBoard;
    IBOutlet UIButton *buttonPlay, *buttonMusic, *buttonGameMode;
    IBOutlet UIButton *buttonBeginner, *buttonIntermediate, *buttonExpert;
    UIActionSheet *actionSheet;
}
    
- (IBAction) buttonPlay_click:(id)sender;
- (IBAction) buttonBuy_click:(id)sender;
- (void) reloadInputViews;

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;
@property (retain, nonatomic) IBOutlet UIButton *buttonPlay;
@property (retain, nonatomic) IBOutlet UIButton *buttonMusic;
@property (retain, nonatomic) IBOutlet UIButton *buttonGameMode;
@property (retain, nonatomic) IBOutlet UIButton *buttonBeginner;
@property (retain, nonatomic) IBOutlet UIButton *buttonIntermediate;
@property (retain, nonatomic) IBOutlet UIButton *buttonExpert;
@property (retain, nonatomic) UIPopoverController *popoverController;
@property (readwrite, nonatomic) ViewController *thisParentViewController;
@property (readwrite, nonatomic) eGameMode gameMode;
@property (retain, nonatomic) NSArray *inAppProdcuts;
    
@end
