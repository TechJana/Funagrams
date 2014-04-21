//
//  Modes.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/20/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Modes : NSManagedObject

@property (nonatomic, retain) NSNumber * hintsPercentile;
@property (nonatomic, retain) NSString * modeDescription;
@property (nonatomic, retain) NSNumber * modeId;
@property (nonatomic, retain) NSSet *games;
@end

@interface Modes (CoreDataGeneratedAccessors)

- (void)addGamesObject:(Games *)value;
- (void)removeGamesObject:(Games *)value;
- (void)addGames:(NSSet *)values;
- (void)removeGames:(NSSet *)values;

@end
