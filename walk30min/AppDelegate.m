//
//  AppDelegate.m
//  walk30min
//
//  Created by YuriHan on 13. 9. 25..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMapViewController.h"

@interface AppDelegate ()
-(void)toast:(NSNotification*)notif;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
	
	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
	[UINavigationBar appearance].tintColor = [UIColor whiteColor];
	//http://b2cloud.com.au/how-to-guides/bar-color-calculator-for-ios7
	//http://stackoverflow.com/questions/18895252/get-the-right-color-in-ios7-translucent-navigation-bar
	[UINavigationBar appearance].barTintColor = [UIColor colorWithRed:59.0/255 green:153.0/255 blue:204.0/255 alpha:1.0];

	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	self.window.rootViewController = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController" bundle:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toast:) name:@"toast" object:nil];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)toast:(NSNotification*)notif
{
    
    NSString* toast = notif.object;
    CGSize sz = [toast sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(320, 40) lineBreakMode:NSLineBreakByCharWrapping];
    UIView* toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sz.width+15,sz.height+8)];
    UIView* boxView = [[UIView alloc] initWithFrame:toastView.bounds];
    boxView.layer.cornerRadius = 10;
    boxView.backgroundColor = [UIColor blackColor];
    boxView.alpha = 0.5f;
    [toastView addSubview:boxView];
    
    UILabel* lb = [[UILabel alloc] initWithFrame:toastView.bounds];
    lb.text = toast;
    lb.backgroundColor = [UIColor clearColor];
    lb.textColor = [UIColor whiteColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.numberOfLines = 2;
    lb.lineBreakMode = NSLineBreakByCharWrapping;
    lb.font = [UIFont systemFontOfSize:12.0f];
    [toastView addSubview:lb];
    toastView.alpha = 0.0f;
    toastView.center = CGPointMake(self.window.center.x,self.window.center.y+150);
    [self.window addSubview:toastView];
    [UIView animateWithDuration:0.5f animations:^(void)
     {
         toastView.alpha = 1.0f;
     }completion:^(BOOL finished){
         [UIView animateWithDuration:2.0f animations:^(void)
          {
              toastView.alpha = 0.99f;
          }completion:^(BOOL finished){
              [UIView animateWithDuration:0.5f animations:^(void)
               {
                   toastView.alpha = 0.0f;
               }completion:^(BOOL finished){
                   [toastView removeFromSuperview];
               }];
          }];
     }];
}

@end
