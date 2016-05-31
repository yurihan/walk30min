//
//  DetailViewController.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "DetailViewController.h"
#import "ReviewTableViewCell.h"
#import "PortalTableViewCell.h"
#import "WebViewController.h"
#import "Utility.h"
#import "NetworkManager.h"
#import "DejalActivityView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageViewer.h"

@interface DetailViewController ()
-(void)done;
-(IBAction)imagePaging:(UIButton*)sender;
-(void)resetPagingButton:(int)pagingNum;
-(IBAction)like:(id)sender;
-(IBAction)searchEngine:(UIButton*)sender;
-(IBAction)review:(id)sender;
-(IBAction)viewPosition:(id)sender;
@end

@implementation DetailViewController

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
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(done)];
	
	UIView* colourView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 64)];
	[colourView setBackgroundColor:[UIColor colorWithRed:0 green:0.35 blue:0.92 alpha:1]];
	[colourView setAlpha:0.38];

	[self.navigationController.navigationBar insertSubview:colourView atIndex:1];
	
	self.title = _info[@"data"][@"name"];
	address.text = _info[@"data"][@"address"];
	
	CLLocationCoordinate2D poiCoord = CLLocationCoordinate2DMake([_info[@"data"][@"katech_Y"] floatValue], [_info[@"data"][@"katech_X"] floatValue]);
	float dist = sqrt((poiCoord.longitude-_refCoord.longitude)*(poiCoord.longitude-_refCoord.longitude)+(poiCoord.latitude-_refCoord.latitude)*(poiCoord.latitude-_refCoord.latitude));
	distance.text = [NSString stringWithFormat:@"%.2f",dist/1000];
	likeCounter.text = [NSString stringWithFormat:@"%d",((NSArray*)_info[@"data"][@"likes"]).count];
	
	[mainScrollView addSubview:contentsView];
	mainScrollView.contentSize = contentsView.bounds.size;
	
	id<NSObject> naver = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"];
	if([naver isKindOfClass:[NSArray class]])
	{
		if(((NSArray*)naver).count == 0)
		{
			currentSearchEngine = 1;
			searchBackImg.image = [UIImage imageNamed:@"Detail_google_bar.png"];
			[portalTableView reloadData];
		}
	}

	reviewCounter.text = [NSString stringWithFormat:@"%d",((NSArray*)_info[@"data"][@"comments"]).count];
	
	imageScrollView.contentSize = CGSizeMake(320*((NSArray*)_info[@"images"]).count, 190);
	for(int i = 0 ;i<((NSArray*)_info[@"images"]).count;i++)
	{
		NSDictionary* image = _info[@"images"][i];
		dispatch_queue_t dq = dispatch_queue_create("lazyLoading", NULL);
		dispatch_async(dq, ^{
			@autoreleasepool {
				UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*320, 0, 320, 220)];
				imgView.contentMode = UIViewContentModeScaleAspectFill;
				UIActivityIndicatorView* ind = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
				dispatch_sync(dispatch_get_main_queue(), ^{
					imgView.backgroundColor = [UIColor blackColor];
					imgView.alpha = 0.3;
					
					ind.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
					ind.center = CGPointMake(320/2, 220/2);
					ind.alpha = 1.0f;
					[imgView addSubview:ind];
					[ind startAnimating];
					[imageScrollView addSubview:imgView];
				});
				NSError* error = nil;
				NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image[@"image_url"]] options:NSDataReadingMappedAlways error:&error];
				if(error == nil)
				{
//					CGSize size = CGSizeMake(320, 220);
//					if([[UIScreen mainScreen] bounds].size.height == 568)
//						size = CGSizeMake(320*2, 220*2);
					UIImage* img = [UIImage imageWithData:data];
					//img = [Utility makeThumbnailImage:img onlyCrop:NO Size:size];
					dispatch_sync(dispatch_get_main_queue(), ^{
						[ind stopAnimating];
						[ind removeFromSuperview];
						imgView.alpha = 1.0;
						imgView.image = img;
						[imgView setupImageViewer];
						imgView.clipsToBounds = YES;
					});
				}
				else
				{
					dispatch_sync(dispatch_get_main_queue(), ^{
						[ind stopAnimating];
						[ind removeFromSuperview];
						imgView.alpha = 1.0;
						UILabel* label = [[UILabel alloc] initWithFrame:imgView.bounds];
						label.backgroundColor = [UIColor clearColor];
						label.textColor = [UIColor whiteColor];
						label.textAlignment = NSTextAlignmentCenter;
						label.text = @"이미지 로딩에 실패하였습니다";
						[imgView addSubview:label];
					});
				}
			}
		});
	}
	if(((NSArray*)_info[@"data"][@"comments"]).count == 0)
	{
		reviewTableView.hidden = YES;
		searchView.center = CGPointMake(searchView.center.x, searchView.center.y-200);
		CGSize size = mainScrollView.contentSize;
		size.height = size.height-200;
		mainScrollView.contentSize = size;
	}
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

-(IBAction)imagePaging:(UIButton*)sender
{
	[self resetPagingButton:sender.tag];
	[imageScrollView scrollRectToVisible:CGRectMake(320*sender.tag, 0, 320, 220) animated:YES];
}

-(void)resetPagingButton:(int)pagingNum
{
	for(int i=0;i<5;i++)
	{
		UIButton* btn = [self valueForKey:[NSString stringWithFormat:@"btnImg%d",i+1]];
		[btn setImage:[UIImage imageNamed:i==pagingNum?@"Detail_img_on.png":@"Detail_img_off.png"] forState:UIControlStateNormal];
	}
}

-(IBAction)like:(id)sender
{
	dispatch_queue_t dq = dispatch_queue_create("loadingQueue", NULL);
	dispatch_async(dq, ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView activityViewForView:self.navigationController.view];
            });
            NSDictionary* ret = [NetworkManager like:[_info[@"id"] stringValue]];
			if(ret == nil)
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"통신상태를 확인하시고 다시한번 시도해주세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
				});
			}
			if([@200 isEqualToNumber:ret[@"meta"][@"code"]])
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					[DejalBezelActivityView removeViewAnimated:YES];
					likeCounter.text = [NSString stringWithFormat:@"%d",likeCounter.text.intValue + 1];
				});
			}
			else if([@"SameIpException" isEqualToString:ret[@"meta"][@"error_type"]])
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					[DejalBezelActivityView removeViewAnimated:YES];
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"좋아요는 한번만 가능해요!" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
				});
			}

		}
	});
}
-(IBAction)searchEngine:(UIButton*)sender
{
	if(currentSearchEngine == sender.tag)
		return;
	currentSearchEngine = sender.tag;
	switch (sender.tag) {
		case 0: // naver
			searchBackImg.image = [UIImage imageNamed:@"Detail_naver_bar.png"];
			break;
		case 1: // google
			searchBackImg.image = [UIImage imageNamed:@"Detail_google_bar.png"];
			break;
		default:
			break;
	}
	[portalTableView reloadData];
}

-(IBAction)review:(id)sender
{
	//[rwv show:[UIApplication sharedApplication].delegate.window];
	[rwv show:self idx:[_info[@"id"] stringValue] delegate:self];
}

-(IBAction)viewPosition:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^(void){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"viewPosition" object:_info];
	}];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if(scrollView == imageScrollView)
	{
		int offset = (scrollView.contentOffset.x+160) / 320;
		//UIButton* btn = [self valueForKey:[NSString stringWithFormat:@"btnImg%d",offset+1]];
		//if(!btn.isSelected)
		//{
			[self resetPagingButton:offset];
		//}
	}
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(tableView == reviewTableView)
	{
		return ((NSArray*)_info[@"data"][@"comments"]).count;
	}
	else
	{

		switch (currentSearchEngine) {
			case 0: // naver
			{
				id<NSObject> naver = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"];
				if([naver isKindOfClass:[NSArray class]])
				{
					return ((NSArray*)_info[@"naver_search_result"][@"rss"][@"channel"][@"item"]).count;
				}
				else return 1;
			}
				break;
			case 1: // google
				return ((NSArray*)_info[@"google_search_result"]).count;
				break;
			default:
				break;
		}
	}
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = nil;
	if(tableView == reviewTableView)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"reviewTableViewCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReviewTableViewCell" owner:self options:nil];
			cell = (ReviewTableViewCell*)[nib objectAtIndex:0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		((ReviewTableViewCell*)cell).reviewPhoto.layer.cornerRadius = 10.0f;
		((ReviewTableViewCell*)cell).reviewPhoto.imageView.layer.cornerRadius = 10.0f;
		((ReviewTableViewCell*)cell).reviewPhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
		
		NSDictionary* review = _info[@"data"][@"comments"][indexPath.row];
		((ReviewTableViewCell*)cell).contents.text = [((NSString*)review[@"text"]) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		((ReviewTableViewCell*)cell).ip.text = review[@"ip"];
		
		dispatch_queue_t dq = dispatch_queue_create("lazyLoading", NULL);
		dispatch_async(dq, ^{
			@autoreleasepool {
				UIActivityIndicatorView* ind = [[UIActivityIndicatorView alloc] initWithFrame:((ReviewTableViewCell*)cell).reviewPhoto.bounds];
				dispatch_sync(dispatch_get_main_queue(), ^{
					ind.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
					//ind.center = ((ReviewTableViewCell*)cell).reviewPhoto.center;
					ind.alpha = 1.0f;
					[((ReviewTableViewCell*)cell).reviewPhoto addSubview:ind];
					[ind startAnimating];
				});
				NSError* error = nil;
				NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://54.248.230.232/" stringByAppendingString:review[@"photo"]]] options:NSDataReadingMappedAlways error:&error];
				if(error == nil)
				{
					dispatch_sync(dispatch_get_main_queue(), ^{
						UIImage* img = [UIImage imageWithData:data];
						[ind stopAnimating];
						[ind removeFromSuperview];
						((ReviewTableViewCell*)cell).reviewPhoto.alpha = 1.0;
						[((ReviewTableViewCell*)cell).reviewPhoto setImage:img forState:UIControlStateNormal];
						//[((ReviewTableViewCell*)cell).reviewPhoto addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
						[((ReviewTableViewCell*)cell).reviewPhoto.imageView setupImageViewer];
						((ReviewTableViewCell*)cell).reviewPhoto.imageView.clipsToBounds = YES;
					});
				}
				else
				{
					dispatch_sync(dispatch_get_main_queue(), ^{
						[ind stopAnimating];
						[ind removeFromSuperview];
						((ReviewTableViewCell*)cell).reviewPhoto.alpha = 1.0;
						UILabel* label = [[UILabel alloc] initWithFrame:((ReviewTableViewCell*)cell).reviewPhoto.bounds];
						label.backgroundColor = [UIColor clearColor];
						label.textColor = [UIColor whiteColor];
						label.textAlignment = NSTextAlignmentCenter;
						label.text = @"이미지 로딩에 실패하였습니다";
						[((ReviewTableViewCell*)cell).reviewPhoto addSubview:label];
					});
				}
			}
		});
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"portalTableViewCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PortalTableViewCell" owner:self options:nil];
			cell = (PortalTableViewCell*)[nib objectAtIndex:0];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		switch (currentSearchEngine) {
			case 0: // naver
			{
				NSDictionary* info = nil;
				id<NSObject> naver = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"];
				if([naver isKindOfClass:[NSArray class]])
				{
					info = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"][indexPath.row];
				}
				else
				{
					info = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"];
				}
				NSString* title = info[@"title"];
				title = [title stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
				title = [title stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
				
				((PortalTableViewCell*)cell).title.text = title;
				NSString* con = info[@"description"];
				con = [con stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
				con = [con stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
				((PortalTableViewCell*)cell).contents.text = con;
				break;
			}
			case 1: // google
			{
				NSDictionary* info = _info[@"google_search_result"][indexPath.row];
				((PortalTableViewCell*)cell).title.text = info[@"title"];
				((PortalTableViewCell*)cell).contents.text = info[@"snippet"];
				break;
			}
			default:
				break;
		}
	}
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 100.0f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

	NSString* link = nil;
	if(tableView == reviewTableView)
	{
		//UIImage* img = ((ReviewTableViewCell*)cell).reviewPhoto.image;
		return;
	}
	else
	{
		switch (currentSearchEngine) {
			case 0: // naver
			{
				id<NSObject> naver = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"];
				if([naver isKindOfClass:[NSArray class]])
				{
					link = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"][indexPath.row][@"link"];
				}
				else
				{
					link = _info[@"naver_search_result"][@"rss"][@"channel"][@"item"][@"link"];
				}
			}
				break;
			case 1: // google
				link = _info[@"google_search_result"][indexPath.row][@"link"];
				break;
			default:
				break;
		}
	}
	NSLog(@"link = %@",link);
	WebViewController* wvc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
	wvc.startUrl = link;
	UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:wvc];
	nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:nvc animated:YES completion:nil];
}

-(void)reviewSuccess
{
	//redraw..
	dispatch_queue_t dq = dispatch_queue_create("loadingQueue", NULL);
	dispatch_async(dq, ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView activityViewForView:self.navigationController.view];
            });
            NSDictionary* placeInfo = [NetworkManager placeInfo:_info[@"id"]];
			if(placeInfo == nil)
			{
				
			}
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView removeViewAnimated:YES];
				_info = placeInfo;
				[reviewTableView reloadData];
				reviewCounter.text = [NSString stringWithFormat:@"%d",((NSArray*)_info[@"data"][@"comments"]).count];
				
				if(reviewTableView.hidden == YES)
				{
					reviewTableView.hidden = NO;
					searchView.center = CGPointMake(searchView.center.x, searchView.center.y+200);
					CGSize size = mainScrollView.contentSize;
					size.height = size.height+200;
					mainScrollView.contentSize = size;
				}
			});
		}
	});
}
@end
