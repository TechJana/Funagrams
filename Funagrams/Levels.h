//
//  Levels.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/20/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Levels : NSManagedObject

@property (nonatomic, retain) NSString * levelDescription;
@property (nonatomic, retain) NSNumber * levelId;
@property (nonatomic, retain) NSSet *games;
@end

@interface Levels (CoreDataGeneratedAccessors)

- (void)addGamesObject:(Games *)value;
- (void)removeGamesObject:(Games *)value;
- (void)addGames:(NSSet *)values;
- (void)removeGames:(NSSet *)values;

@end
