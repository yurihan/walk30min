//
//  ReviewWriteView.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 13..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "ReviewWriteView.h"
#import "DejalActivityView.h"
#import "NetworkManager.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "KakaoLinkCenter.h"
@interface ReviewWriteView ()
-(IBAction)sns:(UIButton*)sender;
-(IBAction)picture:(UIButton*)sender;
-(IBAction)send:(id)sender;
-(IBAction)cancel:(id)sender;
-(void)postFacebook:(NSString*)text image:(UIImage*)image;
-(void)postTwitter:(NSString*)text image:(UIImage*)image;
-(void)postKakao:(NSString*)text image:(UIImage*)image;

@end
@implementation ReviewWriteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)show:(UIViewController*)parentViewController idx:(NSString*)aIdx delegate:(id<ReviewWriteDelegate>) aDelegate
{
	//dispatch_once로 했더니 메인스레드 접근과 관계가 있는지 잘 안됨.
	
	if(firstTime == false)
	{
        if([[UIScreen mainScreen] bounds].size.height-568 == 0)
		{
			boxView.center = CGPointMake(boxView.center.x, boxView.center.y+60);
		}
		btnPicture.imageView.contentMode = UIViewContentModeScaleAspectFill;
		btnPicture.imageView.layer.cornerRadius = 10.0f;
		firstTime = true;
    }
	pvc = parentViewController;
	
    //[[UIApplication sharedApplication].delegate.window addSubview:self];
	[pvc.navigationController.view addSubview:self];
    self.alpha = 0.0f;
	[reviewText becomeFirstResponder];
    [UIView animateWithDuration:0.2f animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
         self.alpha = 1.0f;
     }
		completion:nil];
	idx = aIdx;
	delegate = aDelegate;
}

-(void)hide
{
	[reviewText resignFirstResponder];
    [UIView animateWithDuration:0.2f animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
         self.alpha = 0.0f;
     }
		completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];
}
-(IBAction)sns:(UIButton*)sender
{
	sender.selected = !sender.selected;
	
	if(sender == btnFackbook && sender.selected)
	{
		if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
		{
			UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"페이스북을 사용할 수 없네요.\n설정->페이스북에서 계정을 설정해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[av show];
			sender.selected = !sender.selected;
		}
	}
	else if(sender == btnTwitter && sender.selected)
	{
		if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
		{
			UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"트위터를 사용할 수 없네요.\n설정->트위터에서 트위터 계정을 설정해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[av show];
			sender.selected = !sender.selected;
		}
	}
	else if(sender == btnKakao && sender.selected)
	{
		if (![KakaoLinkCenter canOpenStoryLink])
		{
			UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"카카오스토리가 설치되어있지 않아요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
			[av show];
			sender.selected = !sender.selected;
		}
	}
}
-(IBAction)picture:(UIButton*)sender
{
	UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"사진찍기",@"사진첩", nil];
	[as showInView:[UIApplication sharedApplication].delegate.window];
}
-(IBAction)send:(id)sender
{
	if(hasPhoto == NO)
	{
		UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"사진은 꼭 등록하셔야돼요!" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[av show];
		return;
	}
	
	NSString* tmp = [reviewText.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	tmp = [tmp stringByReplacingOccurrencesOfString:@" " withString:@""];
	if(tmp.length == 0)
	{
		UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"내용을 꼭 입력하셔야돼요!" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[av show];
		return;
	}
	NSString* text = [reviewText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(text.length < 10)
	{
		UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"최소한 10자 이상은 써주세요!" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
		[av show];
		return;
	}
	
	dispatch_queue_t dq = dispatch_queue_create("loadingQueue", NULL);
	dispatch_async(dq, ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView activityViewForView:pvc.view];
            });
			NSDictionary* body = @{@"id":idx,@"text":[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "],@"photo":btnPicture.imageView.image};
            NSDictionary* ret = [NetworkManager review:body];
			if(ret == nil)
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"리뷰 등록에 실패했네요.\n통신상태를 확인하시고 다시 시도해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
					return;
				});
			}
			if([@200 isEqualToNumber:ret[@"meta"][@"code"]])
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					[DejalBezelActivityView removeViewAnimated:YES];
					[self hide];
					if(btnFackbook.selected)
					{
						[self postFacebook:[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "] image:btnPicture.imageView.image];
					}
					else if(btnTwitter.selected)
					{
						[self postTwitter:[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "] image:btnPicture.imageView.image];
					}
					else if(btnKakao.selected)
					{
						[self postKakao:[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "] image:btnPicture.imageView.image];
					}
					else
						[delegate reviewSuccess];
				});
			}
			else
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"알수 없는 이유로 리뷰 등록에 실패했네요.\n통신상태를 확인하시고 다시 시도해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
					return;
				});
			}
		}
	});
}

-(void)postFacebook:(NSString*)text image:(UIImage*)image
{
	SLComposeViewController* fbSheet = [SLComposeViewController
										   composeViewControllerForServiceType:SLServiceTypeFacebook];
	[fbSheet setInitialText:[text stringByAppendingString:@" #걸어서30분"]];
	[fbSheet addImage:image];
	[pvc presentViewController:fbSheet animated:YES completion:nil];
	[fbSheet setCompletionHandler:^(SLComposeViewControllerResult result){
		if(btnTwitter.selected)
		{
			[self postTwitter:text image:btnPicture.imageView.image];
		}
		else if(btnKakao.selected)
		{
			[self postKakao:text image:image];
		}
		else
			[delegate reviewSuccess];
	}];
}
-(void)postTwitter:(NSString*)text image:(UIImage*)image
{
	SLComposeViewController *twSheet = [SLComposeViewController
										   composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twSheet setInitialText:[text stringByAppendingString:@" #걸어서30분"]];
	[twSheet addImage:image];
	[pvc presentViewController:twSheet animated:YES completion:nil];
	[twSheet setCompletionHandler:^(SLComposeViewControllerResult result){
		if(btnKakao.selected)
		{
			[self postKakao:text image:image];
		}
		else
			[delegate reviewSuccess];
	}];
}
-(void)postKakao:(NSString*)text image:(UIImage*)image
{
	[KakaoLinkCenter openStoryLinkWithPost:[text stringByAppendingString:@" #걸어서30분"]
							   appBundleID:[[NSBundle mainBundle] bundleIdentifier]
								appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
								   appName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
								   urlInfo:nil];
	[delegate reviewSuccess];
}
-(IBAction)cancel:(id)sender
{
	[self hide];
}

#pragma mark - Action sheet delegate
// 사진넣기
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: { // 사진찍기
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"카메라를 사용할 수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [alert show];
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //picker.allowsEditing = YES;
            picker.delegate = self;
			[pvc presentViewController:picker animated:YES completion:nil];
        } break;
        case 1: { // 포토라이브러리
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [pvc presentViewController:picker animated:YES completion:nil];
        } break;
    }
}

#pragma mark - ImagePicker controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	/*
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, 100);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, 100, 100), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    picture.image = scaledImage;
    hasPicture = YES;
    */
	[btnPicture setImage:image forState:UIControlStateNormal];
	hasPhoto = YES;
	[picker dismissModalViewControllerAnimated:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
		[picker dismissViewControllerAnimated:YES completion:nil];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)textViewDidChange:(UITextView *)textView
{
	textCounter.text = [NSString stringWithFormat:@"%d/60",textView.text.length];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if (textView.text.length >= 60 && range.length == 0)
		return NO;
	
	return YES;
}
@end
