//
//  LocationTableViewCell.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 4..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell
{
	IBOutlet UILabel* distance;
	IBOutlet UILabel* name;
}
@property (nonatomic,strong) NSDictionary* info;
@end
