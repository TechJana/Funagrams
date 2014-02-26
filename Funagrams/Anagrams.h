//
//  Anagrams.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/22/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categories, Games;

@interface Anagrams : NSManagedObject

@property (nonatomic, retain) NSString * answerText;
@property (nonatomic, retain) NSNumber * anagramId;
@property (nonatomic, retain) NSString * questionText;
@property (nonatomic, retain) Games *games;
@property (nonatomic, retain) NSSet *categories;
@end

@interface Anagrams (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Categories *)value;
- (void)removeCategoriesObject:(Categories *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end