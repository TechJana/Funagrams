//
//  MarketPlaceViewController.h
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/6/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductTableViewCell.h"

@interface MarketPlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *products;
}

@property (strong, nonatomic) IBOutlet UITableView *productTableView;
@property (strong, nonatomic) IBOutlet ProductTableViewCell *productTableCel;
@property (strong, nonatomic) IBOutlet UIButton *buttonBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonRestore;

@end
