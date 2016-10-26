//
//  StereoOverlay.h
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//


#import <MAMapKit/MAMapKit.h>

@interface ReaverOverlay : MAShape<MAOverlay>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@property (nonatomic, readwrite) CLLocationDistance size;

@property (nonatomic, readonly) MAMapRect boundingMapRect;

+ (instancetype)ReaverOverlayWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                             size:(CLLocationDistance)size;

@end
