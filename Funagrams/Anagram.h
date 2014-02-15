//
//  Anagram.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/29/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Anagram : NSObject
{
    NSString *_question;
    NSString *_hint;
    NSString *_result;
    NSString *_levelDescription;
    NSString *_questionRemaining;
    int _level;
}

@property NSString *question;
@property NSString *hint;
@property NSString *result;
@property NSString *levelDescription;
@property NSString *questionRemaining;
@property int level;

@end
