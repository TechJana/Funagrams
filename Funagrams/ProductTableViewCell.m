//
//  ProductTableViewCell.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/6/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "ProductTableViewCell.h"

@implementation ProductTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
