//
//  MainMapViewController.m
//  walk30min
//
//  Created by YuriHan on 13. 9. 29..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "MainMapViewController.h"
#import "BlurViewManager.h"
#import "DetailViewController.h"
#import "LocationTableView.h"
#import "InfoViewController.h"
#import "NetworkManager.h"
#import "Projection.h"
#import "DejalActivityView.h"

enum {
	NMapPOIflagTypeBase = NMapPOIflagTypeReserved,
	
	NMapPOIflagTypePin,
    NMapPOIflagTypeSpot,
	
	NMapPOIflagTypeFrom,
	NMapPOIflagTypeTo,
	NMapPOIflagTypeNumber,
};

@interface MainMapViewController ()
-(void)minuteSliderChanged:(UIButton*)sender;
-(void)minuteSliderEnded;

-(IBAction)info:(UIButton*)sender;
-(IBAction)list:(UIButton*)sender;
-(IBAction)myPos:(UIButton*)sender;
-(void)showDetailInfo:(NSDictionary*)info;
-(void)delayedSearch:(CLLocation*)location;
-(void)viewPosition:(NSNotification*)notif;
@end

@implementation MainMapViewController

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
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

	mapView = [[NMapView alloc] initWithFrame:rect];
	// set delegate for map view
	[mapView setDelegate:self];
	
	// set API key for Open MapViewer Library
	[mapView setApiKey:@"87c76f3caa43d0c6e9b6e0d2442a55d5"];
	[mapView setLogoImageOffsetX:4 offsetY:68];
	
	[self.view insertSubview:mapView atIndex:0];
	
	UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(minuteSliderChanged:)];
	[slider addGestureRecognizer:pgr];
	
	self.edgesForExtendedLayout = UIRectEdgeNone;
	self.extendedLayoutIncludesOpaqueBars = NO;
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewPosition:) name:@"viewPosition" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minuteSliderEnded) name:@"blurViewEnded" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)minuteSliderChanged:(UIPanGestureRecognizer*)sender
{
	static int oldValue = 0;
	
	//px 범위 = 23~297
	CGPoint pt = [sender translationInView:slider];
	[sender setTranslation:CGPointZero inView:slider];
	
	pt = CGPointMake(slider.center.x+pt.x, slider.center.y);

	if(pt.x < 23.0f)
		pt.x = 23.0f;
	else if(pt.x > 297.0f)
		pt.x = 297.0f;
	
	slider.center = pt;
	sliderLeft.frame = CGRectMake(sliderLeft.frame.origin.x, sliderLeft.frame.origin.y, pt.x-23, sliderLeft.frame.size.height);
	sliderRight.frame = CGRectMake(pt.x, sliderRight.frame.origin.y, 297-pt.x, sliderRight.frame.size.height);
	
	int value = (pt.x-23)/((float)(297-23)/30)+30;
	
	if(value == oldValue)
		return;
	[slider setTitle:[NSString stringWithFormat:@"%d",value] forState:UIControlStateNormal];
	
	[[BlurViewManager shared] insertView:self.view text:[NSString stringWithFormat:@"%d분",value]];
	
	oldValue = value;

}

-(void)minuteSliderEnded
{
	[self placeSearch:isSuccessed?searchWGSCoord:currentLocation];
}

-(IBAction)info:(UIButton*)sender
{
	InfoViewController* ivc = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:ivc];
	nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:nvc animated:YES completion:nil];
}

-(IBAction)list:(UIButton*)sender
{
	if(!isFirstSearchEnded)
		return;
	LocationTableView* ltv = [[LocationTableView alloc] initWithPOIs:currentInfo coord:searchKatechCoord delegate:self];
	[ltv show:self.view];
}

-(IBAction)myPos:(UIButton*)sender
{
	if(!isFirstSearchEnded)
		return;
	[mapView setMapCenter:NGeoPointMake(currentLocation.longitude, currentLocation.latitude)];
	[self placeSearch:currentLocation];
}

-(void)placeSearch:(CLLocationCoordinate2D)coord
{
	Projection* proj = [[Projection alloc] init];
	searchWGSCoord = coord;
	CLLocationCoordinate2D kat = [proj wgs2kat:coord];
	
	CGPoint pt = slider.center;
	int value = (pt.x-23)/((float)(297-23)/30)+30;
	
	dispatch_queue_t dq = dispatch_queue_create("loadingQueue", NULL);
    dispatch_async(dq, ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView activityViewForView:self.view];
            });
            NSArray* infos = [NetworkManager placeSearch:kat distance:4000.0*((float)value/60)];
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView removeViewAnimated:YES];
				
				NMapOverlayManager* mapOverlayManager = [mapView mapOverlayManager];
				[mapOverlayManager clearOverlays];
				pathOverlay = nil;
				poiDataOverlay = nil;
				
				if(infos.count == 0)
				{
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"주변에 검색되는 곳이 없네요..\n시간을 좀 더 늘려보시거나 위치를 옮겨보시는 건 어떨까요?" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
					isSuccessed = false;
					NMapOverlayManager* mapOverlayManager = [mapView mapOverlayManager];
					[mapOverlayManager clearOverlays];
					NMapPOIdataOverlay* loc = [mapOverlayManager newPOIdataOverlay];
					[loc initPOIdata:1];
					NMapPOIitem* centerItem = [loc addPOIitemAtLocation:NGeoPointMake(currentLocation.longitude, currentLocation.latitude) title:nil type:NMapPOIflagTypeLocation iconIndex:0 withObject:nil];
					
					[centerItem setPOIflagMode:NMapPOIflagModeFixed];
					centerItem.hasRightCalloutAccessory = NO;
					[loc endPOIdata];

					return;
				}
				isSuccessed = true;
				
				currentInfo = infos;
				searchKatechCoord = kat;
				
				/*
				NMapRadiusSettingOverlay* radiusOverlay = [mapOverlayManager newRadiusSettingOverlay];

				radiusOverlay.radius = 2000;
				radiusOverlay.location = NGeoPointMake(coord.longitude,coord.latitude);
				 */
				// add circle data
				NMapPathDataOverlay *pathDataOverlay = [mapOverlayManager newPathDataOverlay:nil];
				NMapCircleData *circleData = [[NMapCircleData alloc] initWithCapacity:1];
				[circleData initCircleData];
				[circleData addCirclePointLongitude:coord.longitude latitude:coord.latitude radius:4000.0*((float)value/60)];
				[circleData endCircleData];
				[pathDataOverlay addCircleData:circleData];
				// set circle style
				NMapCircleStyle *circleStyle = [[NMapCircleStyle alloc] init];
				[circleStyle setLineType:NMapPathLineTypeSolid];
				[circleStyle setFillColor:[UIColor colorWithRed:0 green:153.0/255 blue:204.0/255 alpha:0.1]];
				[circleStyle setStrokeColor:[UIColor whiteColor]];				
				[circleData setCircleStyle:circleStyle];
				
				poiDataOverlay = [mapOverlayManager newPOIdataOverlay];
				
				[poiDataOverlay initPOIdata:infos.count+1];
				
				NMapPOIitem* centerItem = [poiDataOverlay addPOIitemAtLocation:NGeoPointMake(coord.longitude, coord.latitude) title:nil type:NMapPOIflagTypeLocation iconIndex:0 withObject:nil];
				
				[centerItem setPOIflagMode:NMapPOIflagModeFixed];
				centerItem.hasRightCalloutAccessory = NO;
				
				for(NSDictionary* info in infos)
				{
					NSDictionary* poi = info[@"data"];
					NMapPOIitem* poiItem = [poiDataOverlay addPOIitemAtLocation:NGeoPointMake([poi[@"longitude"] floatValue], [poi[@"latitude"] floatValue]) title:poi[@"name"] type:NMapPOIflagTypePin iconIndex:[info[@"id"] integerValue] withObject:poi];
					
					[poiItem setPOIflagMode:NMapPOIflagModeFixed];
					poiItem.hasRightCalloutAccessory = YES;
				}
				
				
				[poiDataOverlay endPOIdata];
				//[poiDataOverlay showAllPOIdata];
				//[pathDataOverlay showAllPathData];
				int level = value < 45 ? 9 : 8;
				[mapView setMapCenter:NGeoPointMake(coord.longitude,coord.latitude) atLevel:level panToVisibleCenter:YES];
//				if(isFirstSearchEnded)
//					[self list:nil];
				isFirstSearchEnded = true;
            });
        }
	});
}

-(void) onMapView:(NMapView *)_mapView handleLongPressGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded) {
	}
    else if (recognizer.state == UIGestureRecognizerStateBegan){
		CGPoint pt = [recognizer locationInView:recognizer.view];
		NGeoPoint gpt = [_mapView fromPoint:pt];
		[self placeSearch:CLLocationCoordinate2DMake(gpt.latitude, gpt.longitude)];
	}
}

-(void)locationTableView:(LocationTableView*)tableView location:(NSDictionary*)info
{
	[self showDetailInfo:info];
}

-(void)showDetailInfo:(NSDictionary*)info
{
	dispatch_queue_t dq = dispatch_queue_create("loadingQueue", NULL);
	dispatch_async(dq, ^{
        @autoreleasepool {
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView activityViewForView:self.view];
            });
            NSDictionary* placeInfo = [NetworkManager placeInfo:info[@"id"]];
			if(placeInfo == nil)
			{
				dispatch_sync(dispatch_get_main_queue(), ^{
					UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"이런!" message:@"데이터를 가져오지 못했네요.\n통신상태를 확인하시고 다시한번 시도해보세요." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
					[av show];
					return;
				});
			}
            dispatch_sync(dispatch_get_main_queue(), ^{
				[DejalBezelActivityView removeViewAnimated:YES];
				DetailViewController* dvc = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
				UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:dvc];
				dvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
				dvc.info = placeInfo;
				dvc.refCoord = searchKatechCoord;
				[self presentViewController:nvc animated:YES completion:nil];
			});
		}
	});
}

- (void) onMapView:(NMapView *)aMapView initHandler:(NMapError *)error
{
	if (error == nil) { // success
		// set map center and level
		[mapView setMapCenter:NGeoPointMake(126.978371, 37.5666091) atLevel:11];
		locationManager = [NMapLocationManager getSharedInstance];
		[locationManager setDelegate:self];
		[locationManager startContinuousLocationInfo];
		
	} else { // fail
		NSLog(@"onMapView:initHandler: %@", [error description]);
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"네이버 지도 오류" message:[error description]
													   delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
		[alert show];
	}
}

- (void) onMapView:(NMapView *)mapView networkActivityIndicatorVisible:(BOOL)visible {
	//NSLog(@"onMapView:networkActivityIndicatorVisible: %d", visible);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}

-(void) locationManager:(NMapLocationManager *)locationManager didUpdateToLocation:(CLLocation *)location
{
	static bool isFirstTime = YES;
	currentLocation = location.coordinate;
//	NSLog(@"%f/%f",currentLocation.longitude,currentLocation.latitude);
	if(isFirstTime == YES)
	{
		isFirstTime = NO;
		[mapView setMapCenter:NGeoPointMake(location.coordinate.longitude, location.coordinate.latitude)];
		//[self performSelector:@selector(delayedSearch:) withObject:location afterDelay:0.3f];
		[self placeSearch:location.coordinate];
	}
	if(!isSuccessed && isFirstSearchEnded)
	{
		NMapOverlayManager* mapOverlayManager = [mapView mapOverlayManager];
		[mapOverlayManager clearOverlays];
		NMapPOIdataOverlay* loc = [mapOverlayManager newPOIdataOverlay];
		[loc initPOIdata:1];
		NMapPOIitem* centerItem = [loc addPOIitemAtLocation:NGeoPointMake(currentLocation.longitude, currentLocation.latitude) title:nil type:NMapPOIflagTypeLocation iconIndex:0 withObject:nil];
		
		[centerItem setPOIflagMode:NMapPOIflagModeFixed];
		centerItem.hasRightCalloutAccessory = NO;
		[loc endPOIdata];
	}
}
-(void)delayedSearch:(CLLocation*)location
{
	[self placeSearch:location.coordinate];
}
-(void) locationManager:(NMapLocationManager *)locationManager didFailWithError:(NMapLocationManagerErrorType)errorType
{
	NSString *message = nil;
	
	switch (errorType) {
		case NMapLocationManagerErrorTypeUnknown:
		case NMapLocationManagerErrorTypeCanceled:
		case NMapLocationManagerErrorTypeTimeout:
			message = @"일시적으로 내위치를 확인할 수 없습니다.";
			break;
		case NMapLocationManagerErrorTypeDenied:
			if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0f )
				message = @"위치 정보를 확인할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오.";
			else
				message = @"위치 정보를 확인할 수 없습니다.";
			break;
		case NMapLocationManagerErrorTypeUnavailableArea:
			message = @"현재 위치는 지도내에 표시할 수 없습니다.";
			break;
		case NMapLocationManagerErrorTypeHeading:
//			[self setCompassHeadingValue:kMapInvalidCompassValue];
			break;
		default:
			break;
	}
	
	if (message) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:message
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

-(UIImage *) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay imageForOverlayItem: (NMapPOIitem *)poiItem selected:(BOOL)selected
{
//	if(poiItem.)
	if(poiItem.poiFlagType == NMapPOIflagTypePin)
		return [UIImage imageNamed:@"Home_Location.png"];
	else if(poiItem.poiFlagType == NMapPOIflagTypeLocation)
		return [UIImage imageNamed:@"Home_nowlocation.png"];
	return nil;
}

- (CGPoint) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay anchorPointWithType:(NMapPOIflagType)poiFlagType {
	CGPoint anchorPoint;
	
	switch (poiFlagType) {
		case NMapPOIflagTypePin:
		case NMapPOIflagTypeFrom:
		case NMapPOIflagTypeTo:
			anchorPoint.x = 0.5;
			anchorPoint.y = 1.0;
			break;
			
		case NMapPOIflagTypeLocation:
		case NMapPOIflagTypeLocationOff:
		case NMapPOIflagTypeCompass:
			anchorPoint.x = 0.5;
			anchorPoint.y = 0.5;
			break;
			
		case NMapPOIflagTypeNumber:
			anchorPoint.x = 0.5;
			anchorPoint.y = 0.5;
			break;
			
		default:
			anchorPoint.x = 0.5;
			anchorPoint.y = 1.0;
			break;
	}
	
	return anchorPoint;
}
- (UIImage*) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay imageForCalloutOverlayItem:(NMapPOIitem *)poiItem
		   constraintSize:(CGSize)constraintSize selected:(BOOL)selected
imageForCalloutRightAccessory:(UIImage *)imageForCalloutRightAccessory
		  calloutPosition:(CGPoint *)calloutPosition calloutHitRect:(CGRect *)calloutHitRect {
	UIImage* backImg = [UIImage imageNamed:@"Home_name.png"];
	calloutHitRect->origin = CGPointMake(0, 0);
	calloutHitRect->size  = backImg.size;
	calloutPosition->x = (backImg.size.width)/2;
	calloutPosition->x = roundf(calloutPosition->x);
	
	UIGraphicsBeginImageContextWithOptions(backImg.size, NO, 0.0);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	const float alpha = 1.0;
	[backImg drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeCopy alpha:alpha];

	NSString* name = poiItem.object[@"name"];
	
	if (selected) {
		CGContextSetRGBFillColor(context, 0x9c/255.0, 0xa1/255.0, 0xaa/255.0, 1.0);
	} else {
		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	}
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.alignment = NSTextAlignmentCenter;
	style.lineBreakMode = NSLineBreakByTruncatingMiddle;
	
	NSDictionary *attr = @{NSParagraphStyleAttributeName:style};
	[name drawInRect:CGRectMake(5, 5, backImg.size.width-10, backImg.size.width-20) withAttributes:attr];
	   
	// get image
	UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	
	return myImage;
}
-(void)viewPosition:(NSNotification*)notif
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"locationTableViewHide" object:nil];
	NSDictionary* info = notif.object;
	CLLocationCoordinate2D infoCoord = CLLocationCoordinate2DMake([info[@"data"][@"latitude"] floatValue], [info[@"data"][@"longitude"] floatValue]);
	
	NMapOverlayManager *mapOverlayManager = [mapView mapOverlayManager];
	
	if(pathOverlay != nil)
		[mapOverlayManager removePathDataOverlay:pathOverlay];
	
	// set path data points
	NMapPathData *pathData = [[NMapPathData alloc] initWithCapacity:2];
	
	[pathData initPathData:2];
	[pathData addPathPointLongitude:searchWGSCoord.longitude latitude:searchWGSCoord.latitude lineType:NMapPathLineTypeDash];
	[pathData addPathPointLongitude:infoCoord.longitude latitude:infoCoord.latitude lineType:0];
	[pathData endPathData];
	
	// create path data overlay
	pathOverlay = [mapOverlayManager createPathDataOverlay:pathData];
	[pathOverlay setLineColorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0];
	[pathOverlay setLineWidth:2.0f];
	
	[mapView setMapCenter:NGeoPointMake(infoCoord.longitude,infoCoord.latitude) atLevel:14 panToVisibleCenter:YES];
	
//	[poiDataOverlay selectPOIitemWithObject:info];
}
//-(CGPoint)onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay calloutOffsetWithType:(NMapPOIflagType)poiFlagType
//{
//	return CGPointMake(0, 0);
//}
-(BOOL) onMapOverlay:(NMapPOIdataOverlay *)poiDataOverlay didSelectCalloutOfPOIitemAtIndex: (int)index withObject:(id)object
{
	[self showDetailInfo:object];
	return YES;
}
@end
