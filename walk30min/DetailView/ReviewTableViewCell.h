//
//  ReviewTableViewCell.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 19..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
typedef enum
{
	kFacebook = 1<<0,
	kTwitter = 1<<1,
	kKakao = 1<<2,
}SNSType;
*/
@interface ReviewTableViewCell : UITableViewCell
{
	/*
	IBOutlet UIImageView* snsFacebook;
	IBOutlet UIImageView* snsTwitter;
	IBOutlet UIImageView* snsKakao;
	 */
}
@property (nonatomic,strong) IBOutlet UILabel* contents;
@property (nonatomic,strong) IBOutlet UIButton* reviewPhoto;
@property (nonatomic,strong) IBOutlet UILabel* ip;
//@property (nonatomic) SNSType snsType;

@end
