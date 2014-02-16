//
//  Anagram.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/29/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "Anagram.h"

@implementation Anagram

@synthesize level;
@synthesize levelDescription;
@synthesize question;
@synthesize questionRemaining;
@synthesize result;
@synthesize hint;
@synthesize hintPercentile;
@synthesize maxHintCount;
@synthesize hintsProvided;
@synthesize userResult;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        // initialize here
        _question = @"";
        _questionRemaining = @"";
        _result = @"";
        _hint = @"";
        _levelDescription = @"";
        _level = -1;
        _hintPercentile = 1;
        _maxHintCount = 1;
        _hintsProvided = 0;
        _userResult = @"";
    }
    
    return self;
}


@end
