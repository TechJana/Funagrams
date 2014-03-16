//
//  ImageLabelView.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 3/14/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageLabelView : UIImageView

+(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point;

@end