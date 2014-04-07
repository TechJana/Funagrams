//
//  ProductTableViewCell.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/6/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *imageProduct;
@property (retain, nonatomic) IBOutlet UILabel *labelTitle;
@property (retain, nonatomic) IBOutlet UILabel *labelDescription;
@property (retain, nonatomic) IBOutlet UILabel *labelPrice;

@end
