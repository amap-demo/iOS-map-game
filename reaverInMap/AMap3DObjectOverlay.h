//
//  AMap3DObjectOverlay.h
//  reaverInMap
//
//  Created by xiaoming han on 16/8/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface AMap3DObjectOverlay : NSObject<MAOverlay>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance size;
@property (nonatomic, assign) CGFloat altitude;
@property (nonatomic, strong) NSString *textureName;
@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, readonly) float *vertexPointer;
@property (nonatomic, readonly) float *normalPointer;
@property (nonatomic, readonly) float *texCoordPointer;
@property (nonatomic, readonly) unsigned int vertsNum;

+ (instancetype)objectOverlayWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                             size:(CLLocationDistance)size
                                    vertexPointer:(float *)vertexPointer
                                    normalPointer:(float *)normalPointer
                                  texCoordPointer:(float *)texCoordPointer
                                         vertsNum:(unsigned int)vertsNum;

@end
