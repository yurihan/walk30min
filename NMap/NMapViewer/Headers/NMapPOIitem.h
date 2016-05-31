//
//  NMapPOIitem.h
//  MapViewer
//
//  Created by KJKIM on 10. 10. 26..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "NMapGeometry.h"

//
// POI flag type
//
typedef int NMapPOIflagType;

//
// POI flag type : Reserved
//
enum {
	NMapPOIflagTypeUnknown = 0,

	NMapPOIflagTypeLocation = 10, // show pin object with "Location" icon
	NMapPOIflagTypeLocationOff = 11, // show pin object with "Location Off" icon
	NMapPOIflagTypeCompass = 12,

	NMapPOIflagTypeReserved = 0x100
};

//
// POI flag mode
//
typedef enum {
	NMapPOIflagModeTouch, // set POI item with touch and drag mode
	NMapPOIflagModeDrag, // set POI item with drag mode
	NMapPOIflagModeFixed, // set POI item fixed
	NMapPOIflagModeDispatch // set POI item fixed and dispatchable
} NMapPOIflagMode;

//
// for POI object handling
//
@interface NMapPOIitem : NSObject
{
	// title
	NSString *title;
	NSString *snippet;
	NSString *head;
	NSString *tail;

	NGeoPoint _location;
	NPoint _utmk;

	// refer to NMapPOIflagType
	int poiFlagType;
	int iconIndex;

	BOOL isFloating; // is floating or not
	BOOL hasTouchMode; // has touch mode or not
	BOOL isDispatchable; // dispatchable or not

	id object; // object passed to the delegate

	// anchor point for image layer
	CALayer *imgLayer;
	CGPoint anchorPoint;
	BOOL hasRightCalloutAccessory;

	BOOL animationEnabled;
	BOOL keepSelected;

	// position for screen coordinate at the current level
	NGPoint position;
	CGPoint screenLocation;

	// to manage overlapped item
	CGPoint positionSpread;
	int orderId; // to sort pins when spreaded
	BOOL isSpreadable;

	// info layer
	CALayer *infoLayer;
	CGPoint offsetOfInfoLayer;
}

// internal variables
@property (nonatomic, assign) NGPoint position;
@property (nonatomic, assign) CGPoint screenLocation;
@property (nonatomic, assign) CGPoint positionSpread;
@property (nonatomic, assign) int orderId;
@property (nonatomic, assign) BOOL isSpreadable;
@property (nonatomic, retain) CALayer *imgLayer;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, retain) CALayer *infoLayer;
@property (nonatomic, assign) CGPoint infoLayerOffset;

// frame of this item on map view
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *snippet;
@property (nonatomic, retain) NSString *head;
@property (nonatomic, retain) NSString *tail;

@property (nonatomic, assign) NGeoPoint location;
@property (nonatomic, assign) NPoint utmk;

@property (nonatomic, assign) int poiFlagType;
@property (nonatomic, assign) int iconIndex;

@property (nonatomic, assign) BOOL isFloating;
@property (nonatomic, assign) BOOL hasTouchMode;
@property (nonatomic, assign) BOOL isDispatchable;

@property (nonatomic, retain) id object;

@property (nonatomic, assign) BOOL hasRightCalloutAccessory;

// animation is enabled for touch begin event, default is YES.
@property (nonatomic, assign) BOOL animationEnabled;

// keep selected state after touch up event, default is YES.
@property (nonatomic, assign) BOOL keepSelected;

- (void) setPOIflagMode:(NMapPOIflagMode)mode;
- (BOOL) isPOIflagModeFixed;

- (BOOL) isTitleEmpty;

@end

// internally used
@interface NMapPOIitem (infoLayer)
- (void) setInfoLayerPosition;
@end
