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
@property int levelMaxScore;

@end
