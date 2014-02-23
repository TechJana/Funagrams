//
//  Modes.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/22/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Modes : NSManagedObject

@property (nonatomic, retain) NSNumber * modeId;
@property (nonatomic, retain) NSString * modeDescription;
@property (nonatomic, retain) NSNumber * hintsPercentile;
@property (nonatomic, retain) Games *games;

@end
