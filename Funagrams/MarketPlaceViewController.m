//
//  MarketPlaceViewController.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 4/6/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "MarketPlaceViewController.h"
#import <StoreKit/StoreKit.h>
#import "ViewController.h"
#import "InAppPurchase.h"

@interface MarketPlaceViewController ()

@end

@implementation MarketPlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.productTableView.dataSource = self;
    [self.productTableView setDelegate:self];
    
    // Identify the mainMenu ViewController to get the ScoreBoard object
    NSArray* controllers = self.navigationController.viewControllers;
    ViewController* firstViewController = [controllers objectAtIndex:0];
    while (!firstViewController.inAppFetchCompleted)
    {
        
    }
    products = firstViewController.inAppProdcuts;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)butttonRestore_click:(id)sender
{
    [[InAppPurchase sharedInstance] restoreCompletedTransactions];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    return [products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ProductCell";
    
    ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // you do not need this if you have set ProductCell as identifier in the storyboard (else you can remove the comments on this code)
    //if (cell == nil)
    //    {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    //   }
    
    SKProduct *product = [products objectAtIndex:indexPath.row];

    NSNumberFormatter * _priceFormatter;
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_priceFormatter setLocale:product.priceLocale];

    [cell.labelTitle setText:product.localizedTitle];
    [cell.labelDescription setText:product.localizedDescription];
    [cell.labelPrice setText:[_priceFormatter stringFromNumber:product.price]];
    NSString *imageName = [NSString stringWithFormat:@"%@Image", product.productIdentifier];
    cell.imageProduct.image = [UIImage imageNamed:imageName];
    if ([[InAppPurchase sharedInstance] productPurchased:product.productIdentifier])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = products[indexPath.row];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[InAppPurchase sharedInstance] buyProduct:product];

    // Identify the mainMenu ViewController to get the ScoreBoard object
    NSArray* controllers = self.navigationController.viewControllers;
    ViewController* firstViewController = [controllers objectAtIndex:0];
    while (!firstViewController.inAppProductPurchaseComplete)
    {
        
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:firstViewController.inAppPurchasedProductIndex]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView deselectRowAtIndexPath:[NSIndexPath indexPathWithIndex:firstViewController.inAppPurchasedProductIndex] animated:YES];
}

@end
