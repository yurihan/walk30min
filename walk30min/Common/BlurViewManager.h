//
//  BlurViewManager.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class DRNRealTimeBlurView;
@class BlurView;
@interface BlurViewManager : NSObject
{
	//DRNRealTimeBlurView* blurView;
	BlurView* blurView;
	UILabel* label;
}
+(BlurViewManager*)shared;
-(void)insertView:(UIView*)view text:(NSString*)text;
-(void)removeView;
@end
