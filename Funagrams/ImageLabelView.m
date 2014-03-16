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
    if (CGPointEqualToPoint(CGPointMake(-1, -1), point)) {
        point = CGPointMake(image.size.width/2, image.size.height/2);
    }
    
    UIFont *font = [UIFont boldSystemFontOfSize:50];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    //[style setAlignment:NSCenterTextAlignment];
    NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
    [text drawInRect:CGRectIntegral(rect) withAttributes:attr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
