//
//  InAppPurchase.m
//  Funagrams
//
//  Created by Saravanan ImmaMaheswaran on 2/10/14.
//  Copyright (c) 2014 Pluggables. All rights reserved.
//

#import "InAppPurchase.h"
#import "GlobalConstants.h"

@implementation InAppPurchase

+ (InAppPurchase *)sharedInstance {
    static dispatch_once_t once;
    static InAppPurchase * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      kInAppNoAds,
                                      kInAppSciencePack,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
