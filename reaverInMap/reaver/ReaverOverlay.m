//
//  StereoOverlay.m
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import "ReaverOverlay.h"

@interface ReaverOverlay()

@property (nonatomic, readwrite) MAMapRect boundingMapRect;

@property (nonatomic, assign) BOOL needsUpdateBoundingMapRect;

@end


@implementation ReaverOverlay

@synthesize coordinate          = _coordinate;
@synthesize size                = _size;
@synthesize boundingMapRect     = _boundingMapRect;

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (_coordinate.latitude != coordinate.latitude || _coordinate.longitude != coordinate.longitude)
    {
        _coordinate = coordinate;
        self.needsUpdateBoundingMapRect = YES;
    }
}

- (void)setSize:(CLLocationDistance)size
{
    if (_size != size)
    {
        _size = size;
        self.needsUpdateBoundingMapRect = YES;
    }
}

- (MAMapRect)boundingMapRect
{
    if (self.needsUpdateBoundingMapRect)
    {
        [self constructBoundingMapRect];
        self.needsUpdateBoundingMapRect = NO;
    }
    return _boundingMapRect;
}

- (void)constructBoundingMapRect
{
    MAMapPoint centerPoint = MAMapPointForCoordinate(self.coordinate);
    double lengthInMapPoint = self.size * MAMapPointsPerMeterAtLatitude(self.coordinate.latitude);
    self.boundingMapRect = MAMapRectMake(centerPoint.x - lengthInMapPoint * 0.5, centerPoint.y - lengthInMapPoint * 0.5, lengthInMapPoint, lengthInMapPoint);
}

+ (instancetype)ReaverOverlayWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                   size:(CLLocationDistance)size
{
    return [[self alloc] initWithCenterCoordinate:centerCoordinate size:size];
}

- (instancetype)initWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                            size:(CLLocationDistance)size
{
    if (self = [super init])
    {
        self.coordinate = centerCoordinate;
        self.size = size;
        
        self.needsUpdateBoundingMapRect = NO;
        [self constructBoundingMapRect];
    }
    return self;
}

@end
