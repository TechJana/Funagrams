//
//  Scores.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/20/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Scores : NSManagedObject

@property (nonatomic, retain) NSDate * playedOn;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * scoreId;
@property (nonatomic, retain) NSNumber * starsScored;
@property (nonatomic, retain) Games *game;

@end
