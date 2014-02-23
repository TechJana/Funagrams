//
//  Levels.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/22/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Games;

@interface Levels : NSManagedObject

@property (nonatomic, retain) NSNumber * levelId;
@property (nonatomic, retain) NSString * levelDescription;
@property (nonatomic, retain) Games *games;

@end
