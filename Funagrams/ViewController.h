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

@interface ViewController : UIViewController <GKLocalPlayerListener, UIAlertViewDelegate>
{
    ScoreBoard *scoreBoard;
}

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;

@end
