//
//  AMap3DObjectOverlay.m
//  reaverInMap
//
//  Created by xiaoming han on 16/8/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "AMap3DObjectOverlay.h"

@interface AMap3DObjectOverlay()
{
    float *_vertexPointer;
    float *_normalPointer;
    float *_texCoordPointer;
    unsigned int _vertsNum;
}
@property (nonatomic, readwrite) MAMapRect boundingMapRect;
@property (nonatomic, assign) BOOL needsUpdateBoundingMapRect;

@end

@implementation AMap3DObjectOverlay

+ (instancetype)objectOverlayWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                             size:(CLLocationDistance)size
                                    vertexPointer:(float *)vertexPointer
                                    normalPointer:(float *)normalPointer
                                  texCoordPointer:(float *)texCoordPointer
                                         vertsNum:(unsigned int)vertsNum
{
    return [[self alloc] initWithCenterCoordinate:centerCoordinate size:size vertexPointer:vertexPointer normalPointer:normalPointer texCoordPointer:texCoordPointer vertsNum:vertsNum];
}

- (instancetype)initWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                    size:(CLLocationDistance)size
                           vertexPointer:(float *)vertexPointer
                           normalPointer:(float *)normalPointer
                         texCoordPointer:(float *)texCoordPointer
                                vertsNum:(unsigned int)vertsNum
{
    if (self = [super init])
    {
        self.coordinate = centerCoordinate;
        self.size = size;
        _vertexPointer = vertexPointer;
        _normalPointer = normalPointer;
        _texCoordPointer = texCoordPointer;
        _vertsNum = vertsNum;
        self.needsUpdateBoundingMapRect = NO;
        [self constructBoundingMapRect];
    }
    return self;
}


#pragma mark - Interfaces

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


@end
