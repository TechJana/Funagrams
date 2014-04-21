//
//  Anagram.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/29/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Games.h"

@interface ExtendedAnagram : NSObject
{

}

@property NSString *questionRemaining;
@property NSString *userResult;
@property int maxHintCount;
@property int hintsProvided;
@property NSNumber *gameId;
@property NSNumber *maxScore;
@property NSNumber *anagramId;
@property NSString *answerText;
@property NSString *questionText;
@property NSNumber *levelId;
@property NSString *levelDescription;
@property NSNumber *modeId;
@property NSString *modeDescription;
@property NSNumber *hintsPercentile;
@property NSNumber *categroryId;
@property NSString *categroryDescription;

- (id) init;

@end
