//
//  ScoreBoard.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/25/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreBoard : NSObject
{
    NSMutableDictionary *historyData;
}

@property int32_t total;
@property int currentGameScore;
@property int currentGameLevel;

- (NSMutableDictionary *) history;

@end
