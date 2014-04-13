//
//  Scores.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/12/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Scores : NSManagedObject

@property (nonatomic, retain) NSNumber * gameId;
@property (nonatomic, retain) NSDate * playedOn;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * scoreId;
@property (nonatomic, retain) Games *game;

@end
