//
//  Tile.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/19/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "Tile.h"
#import "ImageLabelView.h"

@implementation Tile

@synthesize image;
@synthesize text;
@synthesize isQuestion;
@synthesize index;
@synthesize highlightDurationInSeconds;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        image = [[UIImageView alloc] init];
        text = @"";
        isQuestion = YES;
        index = -1;
        highlightDurationInSeconds = 4; // default to 4seconds
        
        isTileHighlighted = NO;
    }
    
    return self;
}

- (void) highlightTile
{
    // Highlight the tile
    if (!isTileHighlighted)
    {
        UIImage *img = [ImageLabelView drawText:text
                                        inImage:[UIImage imageNamed:@"TileHighlightImage"]
                                        atPoint:CGPointMake(-1, -1)];
        [image setImage:img];
        
        isTileHighlighted = YES;
        
        // timer for the set duration in seconds
        [NSTimer scheduledTimerWithTimeInterval:highlightDurationInSeconds target:self selector:@selector(fadeOffHighlight:) userInfo:nil repeats:NO];
    }
}

- (void) renderTile
{
    UIImage *img = [ImageLabelView drawText:text
                                    inImage:[UIImage imageNamed:@"TileImage"]
                                    atPoint:CGPointMake(-1, -1)];
    [image setImage:img];
}

- (void)fadeOffHighlight:(id)sender
{
    // fade off the Highlight
    if (isTileHighlighted)
    {
        [self renderTile];
        
        isTileHighlighted = NO;
    }
}

@end
