//
//  MainMapViewController.h
//  walk30min
//
//  Created by YuriHan on 13. 9. 29..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMapView.h"
#import "NMapLocationManager.h"
#import "Protocols.h"

@interface MainMapViewController : UIViewController <NMapViewDelegate, NMapPOIdataOverlayDelegate, MMapReverseGeocoderDelegate, NMapLocationManagerDelegate, LocationTableViewDelegate>
{
	NMapView* mapView;
	NMapLocationManager* locationManager;
	IBOutlet UIButton* slider;
	IBOutlet UIImageView* sliderLeft;
	IBOutlet UIImageView* sliderRight;
	CLLocationCoordinate2D currentLocation;
	CLLocationCoordinate2D searchKatechCoord;
	CLLocationCoordinate2D searchWGSCoord;
	NMapPathDataOverlay* pathOverlay;
	NMapPOIdataOverlay* poiDataOverlay;
	NSArray* currentInfo;
	BOOL isSuccessed;
	BOOL isFirstSearchEnded;
}
@end
