//
//  ViewController.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreBoard.h"

@interface ViewController : UIViewController
{
    ScoreBoard *scoreBoard;
}

@property (nonatomic, retain) ScoreBoard *gameScoreBoard;

@end
