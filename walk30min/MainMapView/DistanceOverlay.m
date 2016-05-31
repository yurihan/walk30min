//
//  DistanceOverlay.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 19..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "DistanceOverlay.h"

@implementation DistanceOverlay
//오버레이 객체를 화면에 표시한다. 경로와 같이 지도 위에 직접 표시되는 오버레이 객체인 경우에 구현한다.
-(void) drawToLayer:(CALayer *)theLayer frame:(CGRect)rect
{
	theLayer.frame = rect;
	theLayer.cornerRadius = 10.0;
	theLayer.contents = (id) [UIImage imageNamed:@"Home_distance.png"].CGImage;
	theLayer.masksToBounds = YES;
}
//오버레이 객체가 화면에서 제거되는 경우에 호출된다. 경로와 같이 지도 위에 직접 표시되는 오버레이 객체인 경우에는 맵뷰의 invalidate 메서드를 호출해야 한다.
-(void) clearOverlay
{
	
}
//오버레이 객체에서 사용하는 타이머를 종료한다. 맵뷰가 비활성화되는 경우에 호출된다.
-(void) stopTimers
{
	[super stopTimers];
}
//오버레이 객체에서 표시하는 레이어들의 위치를 조정한다. 맵뷰의 레이아웃이 변경되면 호출된다.
-(void) layoutSublayers
{
	[super layoutSublayers];
}
//오버레이 객체에서 표시하는 레이어들의 위치를 전달된 변위만큼 이동한다. 지도 패닝 시 호출된다.
-(void) moveByDx:(float)dX dY:(float)dY
{

}
//확대/축소 애니메이션 시작 시에 호출된다. 애니메이션 시작 전에 필요한 작업을 수행한다. 애니메이션 도중에 화면에 표시되는 레이어들의 위치 변경이 필요한 경우에 구현한다.
-(void) initZoomByFactor: (float)zoomFactor near:(CGPoint)pivot
{
	
}
//확대/축소 애니메이션 진행 중에 호출된다. pivot 위치를 중심으로 zoomFactor 배율로 확대 또는 축소된다. 애니메이션 도중에 화면에 표시되는 레이어들의 위치 변경이 필요한 경우에 구현한다.
-(void) zoomByFactor: (float)zoomFactor near:(CGPoint)pivot;
{
	
}
//오버레이 객체에서 지도 위에 직접 경로를 표시하는지 여부를 반환한다.
-(BOOL) hasPathData
{
	return NO;
}

//오버레이 객체에서 표시되는 레이어의 zPosition을 인자로 전달받아 맵뷰 상의 오버레이 레이어의 zPosition으로 반환한다.
-(int) layerZPosition:(int)zPosition
{
	return [super layerZPosition:zPosition];
}
@end
