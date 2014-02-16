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
    float _hintPercentile;
    int _maxHintCount;
    int _hintsProvided;
    NSString *_userResult;
}

@property NSString *question;
@property NSString *hint;
@property NSString *result;
@property NSString *levelDescription;
@property NSString *questionRemaining;
@property int level;
@property float hintPercentile;
@property int maxHintCount;
@property int hintsProvided;
@property NSString *userResult;

@end
