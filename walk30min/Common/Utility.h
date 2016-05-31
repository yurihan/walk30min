//
//  Utility.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 18..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+(UIImage*)makeThumbnailImage:(UIImage*)image onlyCrop:(BOOL)bOnlyCrop Size:(CGSize)size;
@end
