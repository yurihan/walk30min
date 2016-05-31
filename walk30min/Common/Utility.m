//
//  Utility.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 18..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "Utility.h"

@implementation Utility
+(UIImage*)makeThumbnailImage:(UIImage*)image onlyCrop:(BOOL)bOnlyCrop Size:(CGSize)size
{
    CGRect rcCrop;
    if (image.size.width == image.size.height)
    {
        rcCrop = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    }
    else if (image.size.width > image.size.height)
    {
        int xGap = (image.size.width - image.size.height)/2;
        rcCrop = CGRectMake(xGap, 0.0, image.size.height, image.size.height);
    }
    else
    {
        int yGap = (image.size.height - image.size.width)/2;
        rcCrop = CGRectMake(0.0, yGap, image.size.width, image.size.width);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rcCrop);
    UIImage* cropImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    if (bOnlyCrop) return cropImage;
    
    
    NSData* dataCrop = UIImagePNGRepresentation(cropImage);
    UIImage* imgResize = [[UIImage alloc] initWithData:dataCrop];
    
    UIGraphicsBeginImageContext(size);
    [imgResize drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage* imgThumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgThumb;
}
@end
