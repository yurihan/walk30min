//
//  Projection.h
//  walk30min
//
//  Created by YuriHan on 13. 10. 17..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Projection : NSObject
{
    double m_Ind [3];
	double m_Es [3];
	double m_Esp [3];
	double src_m [3];
	double dst_m [3];
    
	
	double m_arMajor [3];
	double m_arMinor [3];
    
	double m_arScaleFactor [3];
	double m_arLonCenter [3];
	double m_arLatCenter [3];
	double m_arFalseNorthing [3];
	double m_arFalseEasting [3];
	
	double datum_params [3];
}
-(CLLocationCoordinate2D) wgs2kat:(CLLocationCoordinate2D)coord;
-(CLLocationCoordinate2D) kat2wgs:(CLLocationCoordinate2D)coord;
@end
