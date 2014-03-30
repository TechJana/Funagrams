//
//  ImageLabelView.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/14/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ImageLabelView.h"

@implementation ImageLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIFont *font = [UIFont boldSystemFontOfSize:30];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        font = [UIFont boldSystemFontOfSize:40];
    }

    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    if (CGPointEqualToPoint(CGPointMake(-1, -1), point)) {
        CGSize textSize;
        textSize = [text sizeWithFont:font];
        point = CGPointMake((image.size.width-textSize.width)/2, (image.size.height-textSize.height)/2);
    }
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor blackColor] set];
    [text drawInRect:CGRectIntegral(CGRectMake(rect.origin.x+1, rect.origin.y+1, rect.size.width, rect.size.height)) withFont:font];
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
