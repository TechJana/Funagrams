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
@synthesize result;
@synthesize hint;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        // initialize here
        _question = @"";
        _result = @"";
        _hint = @"";
        _levelDescription = @"";
        _level = -1;
    }
    
    return self;
}


@end
