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
    }
    
    return self;
}

- (void) setAnagramsBaseFromGames:(Games *)games
{
    self.anagramId = games.anagram.anagramId;
    self.answerText = games.anagram.answerText;
    self.questionText = games.anagram.questionText;
    self.categories = [games.anagram.categories copy];
    self.games = [games copy];
}

@end
