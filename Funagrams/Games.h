//
//  Games.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/22/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anagrams, Levels, Modes, Scores;

@interface Games : NSManagedObject

@property (nonatomic, retain) NSNumber * anagramId;
@property (nonatomic, retain) NSNumber * levelId;
@property (nonatomic, retain) NSNumber * modeId;
@property (nonatomic, retain) NSNumber * gameId;
@property (nonatomic, retain) NSNumber * maxScore;
@property (nonatomic, retain) Anagrams *anagram;
@property (nonatomic, retain) Levels *level;
@property (nonatomic, retain) Modes *mode;
@property (nonatomic, retain) Scores *score;

@end
