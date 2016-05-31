//
//  LocationTableViewCell.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 4..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setInfo:(NSDictionary *)aInfo
{
	_info = aInfo;
	name.text = aInfo[@"name"];
	distance.text = aInfo[@"distance"];
	
}
@end
