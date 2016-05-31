//
//  InfoViewController.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 9..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()
-(void)done;
@end

@implementation InfoViewController

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
	//	self.tintColor =
	self.title = @"정보";
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(done)];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(done)];
	
	UIView* colourView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 64)];
	[colourView setBackgroundColor:[UIColor colorWithRed:0 green:0.35 blue:0.92 alpha:1]];
	[colourView setAlpha:0.38];
	
	[self.navigationController.navigationBar insertSubview:colourView atIndex:1];
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
@end
