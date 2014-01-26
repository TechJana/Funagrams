//
//  ViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/21/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ViewController.h"

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

@end
