//
//  WebViewController.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 20..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate>
{
	IBOutlet UIWebView* webView;
	IBOutlet UIBarButtonItem* back;
	IBOutlet UIBarButtonItem* forward;
	IBOutlet UIToolbar* toolbar;
}
@property (nonatomic,strong) NSString* startUrl;
@end
