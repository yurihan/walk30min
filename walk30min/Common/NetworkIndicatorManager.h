//
//  NetworkIndicatorManager.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 15..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorManager : NSObject
{
    int count;
}
+(NetworkIndicatorManager*)shared;
-(void)showIndicator;
-(void)hideIndicator;
@end
