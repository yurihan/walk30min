//
//  DetailViewController.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ReviewWriteView.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate,ReviewWriteDelegate>
{
	IBOutlet UIScrollView* mainScrollView;
	IBOutlet UIView* contentsView;
	IBOutlet UIButton* btnImg1;
	IBOutlet UIButton* btnImg2;
	IBOutlet UIButton* btnImg3;
	IBOutlet UIButton* btnImg4;
	IBOutlet UIButton* btnImg5;
	
	IBOutlet UILabel* likeCounter;
	IBOutlet UILabel* reviewCounter;
	IBOutlet UILabel* distance;
	IBOutlet UILabel* address;
	IBOutlet UIScrollView* imageScrollView;

	IBOutlet UIView* searchView;
	
	IBOutlet UIImageView* searchBackImg;
	
	int currentSearchEngine;
	
	IBOutlet ReviewWriteView* rwv;
	
	IBOutlet UITableView* portalTableView;
	IBOutlet UITableView* reviewTableView;
}
@property (nonatomic,strong) NSDictionary* info;
@property CLLocationCoordinate2D refCoord;
@end
