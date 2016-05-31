//
//  LocationTableView.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 3..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "LocationTableView.h"
#import "LocationTableViewCell.h"
#import "NMapView.h"

@interface LocationTableView ()
-(void)hide;
@end

@implementation LocationTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(LocationTableView*)initWithPOIs:(NSArray*)_pois coord:(CLLocationCoordinate2D)coord delegate:(id<LocationTableViewDelegate>)delegate
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _delegate = delegate;
        pois = _pois;
		currentCoord = coord;
        // Initialization code
        UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        //backgroundView.backgroundColor = [UIColor blackColor];
		backgroundView.backgroundColor = [UIColor clearColor];
        //backgroundView.alpha = 0.7f;
        [self addSubview:backgroundView];
        
        UIButton* hide = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:hide];
        [hide addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        
		UIImageView* back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 574/2, 688/2)];
		back.image = [UIImage imageNamed:@"Home_List_back.png"];
		back.center = self.center;
		[self addSubview:back];
		
        pinsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 574/2-10, 690/2-10) style:UITableViewStylePlain];
		pinsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		//pinsTableView.separatorColor = [UIColor colorWithRed:174.0/255 green:173.0/255 blue:173.0/255 alpha:1.0f];
		pinsTableView.center = back.center;
        pinsTableView.layer.cornerRadius = 10.0f;
		pinsTableView.backgroundColor = [UIColor clearColor];
        //pinsTableView.layer.borderWidth = 2.0f;
        //pinsTableView.layer.borderColor = [UIColor colorWithRed:0.0f green:1.0f blue:1.0f alpha:0.7f].CGColor;
        pinsTableView.delegate = self;
        pinsTableView.dataSource = self;
		[self addSubview:pinsTableView];
		
		UIButton* btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 68/2, 70/2)];
		[btnClose setImage:[UIImage imageNamed:@"Home_List_x.png"] forState:UIControlStateNormal];
		[btnClose addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		btnClose.center = CGPointMake(pinsTableView.frame.origin.x+pinsTableView.frame.size.width-10, pinsTableView.frame.origin.y+10);
		[self addSubview:btnClose];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide2) name:@"locationTableViewHide" object:nil];
    }
    return self;
}

-(void)show:(UIView*)view
{
    [view addSubview:self];
    self.alpha = 0.0f;
	
    [UIView animateWithDuration:0.2f animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
         self.alpha = 1.0f;
     }
		completion:^(BOOL finished)
     {
//			showFinished = YES;
//            [pinsTableView reloadData];
     }];
}

-(void)hide
{
	static bool isFirstTime = YES;
    [UIView animateWithDuration:0.2f animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
         self.alpha = 0.0f;
     }
					 completion:^(BOOL finished)
     {
         [self removeFromSuperview];
		 //if(isFirstTime)
		 //{
			 Toast(@"다른 위치에서 검색하시려면\n원하시는 위치를 길게 누르세요");
		//	 isFirstTime = NO;
		 //}
		 [[NSNotificationCenter defaultCenter] removeObserver:self];
     }];
}
-(void)hide2
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeFromSuperview];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(showFinished == NO)
//        return 0;
    return pois.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"locationTableViewCell";
    
    LocationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationTableViewCell" owner:self options:nil];
        cell = (LocationTableViewCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	NSDictionary* poi = pois[indexPath.row][@"data"];
	/*
	NGeoPoint pt1 = NGeoPointMake(currentCoord.longitude, currentCoord.latitude);
	NGeoPoint pt2 = NGeoPointMake([poi[@"longitude"] floatValue], [poi[@"latitude"] floatValue]);
	
	float dist = [NMapView distanceFromLocation:pt1 toLocation:pt2]/1000;
	 */
	CLLocationCoordinate2D poiCoord = CLLocationCoordinate2DMake([poi[@"katech_Y"] floatValue], [poi[@"katech_X"] floatValue]);
	float dist = sqrt((poiCoord.longitude-currentCoord.longitude)*(poiCoord.longitude-currentCoord.longitude)+(poiCoord.latitude-currentCoord.latitude)*(poiCoord.latitude-currentCoord.latitude));
	//NSLog(@"%.2fkm",dist);
	//NSLog(@"%f,%f,%f,%f",pt1.longitude,pt1.latitude,pt2.longitude,pt2.latitude);
	cell.info = @{@"name":poi[@"name"],@"distance":[NSString stringWithFormat:@"%.2f",dist/1000]};
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 67.0f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_delegate)
        if([_delegate respondsToSelector:@selector(locationTableView:location:)])
            [_delegate locationTableView:self location:pois[indexPath.row]];
    //[self hide];
}
@end
