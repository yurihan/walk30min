//
//  NetworkManager.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 15..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NetworkManager : NSObject
//+(NetworkManager*)shared;
+(NSArray*)placeSearch:(CLLocationCoordinate2D)coord distance:(int)dist;
+(NSDictionary*)placeInfo:(NSString*)idx;
+(NSDictionary*)review:(NSDictionary*)info;
+(NSDictionary*)like:(NSString*)idx;
@end

