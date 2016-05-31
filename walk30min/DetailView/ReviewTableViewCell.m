//
//  ReviewTableViewCell.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 19..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "ReviewTableViewCell.h"

@interface ReviewTableViewCell ()
@end

@implementation ReviewTableViewCell

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
/*
-(void)setSnsType:(SNSType)snsType
{
	_snsType = snsType;
	if(snsType == (kFacebook|kTwitter|kKakao))
	{
		return;
	}
	else if(snsType == 0)
	{
		snsFacebook.hidden = YES;
		snsTwitter.hidden = YES;
		snsKakao.hidden = YES;
	}
	else if(snsType == kFacebook)
	{
		snsTwitter.hidden = YES;
		snsKakao.hidden = YES;
		snsFacebook.center = snsKakao.center;
	}
	else if(snsType == (kFacebook|kTwitter))
	{
		snsKakao.hidden = YES;
		snsFacebook.center = snsTwitter.center;
		snsTwitter.center = snsKakao.center;
	}
	else if(snsType == kTwitter)
	{
		snsFacebook.hidden = YES;
		snsKakao.hidden = YES;
		snsTwitter.center = snsKakao.center;
	}
	else if(snsType == (kTwitter|kKakao))
	{
		snsFacebook.hidden = YES;
	}
	else if(snsType == kKakao)
	{
		snsFacebook.hidden = YES;
		snsTwitter.hidden = YES;
	}
	return;
}
 */
@end
