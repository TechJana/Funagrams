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

@interface ViewController : UIViewController <GKLocalPlayerListener, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, RNGridMenuDelegate>
{
    ScoreBoard *scoreBoard;
    IBOutlet UIButton *buttonPlay, *buttonMusic;
    IBOutlet UIButton *buttonBeginner, *buttonIntermediate, *buttonExpert;
    UIActionSheet *actionSheet;
    //ViewController *thisParentController;
}
    
- (IBAction) buttonPlay_click:(id)sender;
- (IBAction) buttonBeginner_click:(id)sender;
- (IBAction) buttonIntermediate_click:(id)sender;
- (IBAction) buttonExpert_click:(id)sender;

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;
@property (retain, nonatomic) IBOutlet UIButton *buttonPlay;
@property (retain, nonatomic) IBOutlet UIButton *buttonMusic;
@property (retain, nonatomic) IBOutlet UIButton *buttonBeginner;
@property (retain, nonatomic) IBOutlet UIButton *buttonIntermediate;
@property (retain, nonatomic) IBOutlet UIButton *buttonExpert;
@property (retain, nonatomic) UIPopoverController *popoverController;
@property (readwrite, nonatomic) ViewController *thisParentViewController;
    
@end
