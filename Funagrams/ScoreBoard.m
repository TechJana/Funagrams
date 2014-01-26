//
//  ScoreBoard.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/25/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ScoreBoard.h"

@implementation ScoreBoard

- (id) init
{
    self = [super init];
    
    if (self)
    {
        // initialize here
        historyData = [[NSMutableDictionary alloc] initWithObjectsAndKeys: @"TBD", @"TBD", nil];
        _total = 0;
        self.total = _total;
        _currentGameLevel = 1;
        _currentGameScore = 0;
        self.currentGameLevel = _currentGameLevel;
        self.currentGameScore = _currentGameScore;
    }
    
    return self;
}

- (NSMutableDictionary *) history
{
    
    return historyData;
}

@end
