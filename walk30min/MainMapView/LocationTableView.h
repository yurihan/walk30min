//
//  LocationTableView.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Protocols.h"

typedef enum
{
	kPOINone = 0,
	kPOIHeritage = 1<<0,
	kPOIMuseum = 1<<1,
	kPOIPark = 1<<2,
}POIType;

@interface LocationTableView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* pinsTableView;
    NSArray* pois;
    id<LocationTableViewDelegate> _delegate;
//    bool showFinished;
	CLLocationCoordinate2D currentCoord;
}
-(LocationTableView*)initWithPOIs:(NSArray*)pois coord:(CLLocationCoordinate2D)coord delegate:(id<LocationTableViewDelegate>)delegate;
-(void)show:(UIView*)view;
@end
