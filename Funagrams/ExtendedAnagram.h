//
//  Anagram.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 1/29/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anagrams.h"
#import "Games.h"

@interface ExtendedAnagram : Anagrams
{

}

@property NSString *questionRemaining;
@property NSString *userResult;
@property int maxHintCount;
@property int hintsProvided;

- (id) init;
- (void) setAnagramsBaseFromGames:(Games *)anagrams;

@end
