//
//  NetworkIndicatorManager.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 15..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "NetworkIndicatorManager.h"

@implementation NetworkIndicatorManager
+(NetworkIndicatorManager*)shared
{
    static NetworkIndicatorManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkIndicatorManager alloc] init];
    });
    return sharedInstance;
}

-(void)showIndicator
{
    @synchronized(self)
    {
        count++;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
-(void)hideIndicator
{
    @synchronized(self)
    {
        if(count > 0)
        {
            count--;
        }
        if(count == 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
    
}

@end
