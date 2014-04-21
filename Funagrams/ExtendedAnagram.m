//
//  Anagram.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/29/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ExtendedAnagram.h"

@implementation ExtendedAnagram

@synthesize questionRemaining;
@synthesize userResult;
@synthesize maxHintCount;
@synthesize hintsProvided;
@synthesize gameId;
@synthesize maxScore;
@synthesize anagramId;
@synthesize answerText;
@synthesize questionText;
@synthesize levelId;
@synthesize levelDescription;
@synthesize modeId;
@synthesize modeDescription;
@synthesize hintsPercentile;
@synthesize categroryId;
@synthesize categroryDescription;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        // initialize here
        questionRemaining = @"";
        userResult = @"";
        maxHintCount = 0;
        hintsProvided = 0;
        
#if TEST_MODE_DEF
        questionText = @"DORMITORY";
        questionRemaining = [questionText copy];
        answerText = @"DIRTY ROOM";
        levelId = [NSNumber numberWithInt:1];
        levelDescription = @"Level 1";
        hintsPercentile = [NSNumber numberWithFloat:90.0/100.0];
        hintsProvided = 0;
        maxHintCount = questionText.length * [hintsPercentile floatValue];
        maxScore = [NSNumber numberWithInt:1500];
        userResult = [NSString stringWithFormat:@"%*s", answerText.length, ""];
#endif
    }
    
    return self;
}

@end
