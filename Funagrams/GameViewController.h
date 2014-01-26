//
//  GameViewController.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/24/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface GameViewController : UIViewController
{
    IBOutlet UILabel *labelScore;
    IBOutlet UIButton *buttonHint;
    IBOutlet UIButton *buttonScramble;
    IBOutlet UIButton *buttonCancel;
    IBOutlet UIButton *buttonSubmit;
    IBOutlet UILabel *labelHint;
    IBOutlet UILabel *labelHintValue;
    
    ScoreBoard *scoreBoard;
}

@property (retain, nonatomic) IBOutlet UILabel *labelScore;
@property (retain, nonatomic) IBOutlet UIButton *buttonHint;
@property (retain, nonatomic) IBOutlet UIButton *buttonScramble;
@property (retain, nonatomic) IBOutlet UIButton *buttonCancel;
@property (retain, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (retain, nonatomic) IBOutlet UILabel *labelHint;
@property (retain, nonatomic) IBOutlet UILabel *labelHintValue;

@end
