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

@interface ViewController : UIViewController <GKLocalPlayerListener, UIAlertViewDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    ScoreBoard *scoreBoard;
    IBOutlet UIButton *buttonPlay;
}
    
- (IBAction) buttonPlay_click:(id)sender;
- (IBAction) buttonBeginner_click:(id)sender;
- (IBAction) buttonIntermediate_click:(id)sender;
- (IBAction) buttonExpert_click:(id)sender;

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;
@property (retain, nonatomic) IBOutlet UIButton *buttonPlay;

@end
