//
//  Tile.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/19/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tile : NSObject
{
    BOOL isTileHighlighted;
}

@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, readwrite) BOOL isQuestion;
@property (nonatomic, readwrite) int index;
@property (nonatomic, readwrite) int highlightDurationInSeconds;

- (id) init;
- (void) highlightTile;
- (void) renderTile;

@end
