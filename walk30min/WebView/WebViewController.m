//
//  WebViewController.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 20..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "WebViewController.h"
#import "NetworkIndicatorManager.h"

@interface WebViewController ()
-(IBAction)toolbar:(UIBarButtonItem*)sender;
@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(done)];
	
	UIView* colourView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 64)];
	[colourView setBackgroundColor:[UIColor colorWithRed:0 green:0.35 blue:0.92 alpha:1]];
	[colourView setAlpha:0.38];
	
	[self.navigationController.navigationBar insertSubview:colourView atIndex:1];

	UIView* colourView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[colourView2 setBackgroundColor:[UIColor colorWithRed:0 green:0.35 blue:0.92 alpha:1]];
	[colourView2 setAlpha:0.38];
	[toolbar insertSubview:colourView2 atIndex:1];
	
	NSURL *url = [NSURL URLWithString:self.startUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)done
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)toolbar:(UIBarButtonItem*)sender
{
	switch (sender.tag) {
		case 0:
			[webView goBack];
			break;
		case 1:
			[webView goForward];
			break;
		case 2:
			[webView reload];
			break;
		case 3:
		{
			UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"주소 복사",@"사파리에서 열기", nil];
			[as showInView:[UIApplication sharedApplication].delegate.window];
		}
			break;
		default:
			break;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)_webView
{
    [[NetworkIndicatorManager shared] showIndicator];
    
    back.enabled = webView.canGoBack;
    forward.enabled = webView.canGoForward;
}
-(void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [[NetworkIndicatorManager shared] hideIndicator];
	
    back.enabled = webView.canGoBack;
    forward.enabled = webView.canGoForward;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//  addrField.text = [[request URL] description];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    
//    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
//    [av show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // 복사
            [[UIPasteboard generalPasteboard] setString:webView.request.URL.absoluteString];
			break;
        case 1: // 사파리
			[[UIApplication sharedApplication] openURL:webView.request.URL];
			break;
    }
}

@end
