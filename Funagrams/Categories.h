//
//  Categories.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/22/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anagrams;

@interface Categories : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSString * categoryDescription;
@property (nonatomic, retain) NSSet *anagrams;
@end

@interface Categories (CoreDataGeneratedAccessors)

- (void)addAnagramsObject:(Anagrams *)value;
- (void)removeAnagramsObject:(Anagrams *)value;
- (void)addAnagrams:(NSSet *)values;
- (void)removeAnagrams:(NSSet *)values;

@end
