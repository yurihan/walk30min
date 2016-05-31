//
//  Protocols.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocationTableView;

@protocol LocationTableViewDelegate <NSObject>
@required
-(void)locationTableView:(LocationTableView*)tableView location:(NSDictionary*)info;
@end
