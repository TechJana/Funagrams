//
//  Games.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/12/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anagrams, Levels, Modes, Scores;

@interface Games : NSManagedObject

@property (nonatomic, retain) NSNumber * gameId;
@property (nonatomic, retain) NSNumber * maxScore;
@property (nonatomic, retain) Anagrams *anagram;
@property (nonatomic, retain) Levels *level;
@property (nonatomic, retain) Modes *mode;
@property (nonatomic, retain) NSSet *score;
@end

@interface Games (CoreDataGeneratedAccessors)

- (void)addScoreObject:(Scores *)value;
- (void)removeScoreObject:(Scores *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

@end
