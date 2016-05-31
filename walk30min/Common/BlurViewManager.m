//
//  BlurViewManager.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "BlurViewManager.h"
//#import "DRNRealTimeBlurView.h"
#import "BlurView.h"

@implementation BlurViewManager
+(BlurViewManager*)shared
{
    static BlurViewManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BlurViewManager alloc] init];
		[sharedInstance initialize];

    });
    return sharedInstance;
}

-(void)initialize
{
	//blurView = [[DRNRealTimeBlurView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	blurView = [[BlurView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
	//blurView.renderStatic = NO;
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
	label.font = [UIFont systemFontOfSize:50];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	[blurView addSubview:label];
}

-(void)insertView:(UIView*)view text:(NSString*)text
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeView) object:nil];
	label.text = text;
	blurView.center = CGPointMake(view.bounds.size.width/2,view.bounds.size.height/2);
	[view addSubview:blurView];
	[self performSelector:@selector(removeView) withObject:nil afterDelay:1.0f];
}

-(void)removeView
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"blurViewEnded" object:nil];
	[blurView removeFromSuperview];
}
@end
