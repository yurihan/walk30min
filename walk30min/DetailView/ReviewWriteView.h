//
//  ReviewWriteView.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 13..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReviewWriteDelegate <NSObject>
-(void)reviewSuccess;
@end

@interface ReviewWriteView : UIView <UIImagePickerControllerDelegate,UITextViewDelegate>
{
	UIViewController* pvc;
	IBOutlet UIView* boxView;
	IBOutlet UIButton* btnFackbook;
	IBOutlet UIButton* btnTwitter;
	IBOutlet UIButton* btnKakao;
	IBOutlet UIButton* btnPicture;
	IBOutlet UITextView* reviewText;
	IBOutlet UILabel* textCounter;
	bool firstTime;
	id<ReviewWriteDelegate> delegate;
	NSString* idx;
	bool hasPhoto;
	
}
-(void)show:(UIViewController*)parentViewController idx:(NSString*)idx delegate:(id<ReviewWriteDelegate>) delegate;
-(void)hide;
@end
