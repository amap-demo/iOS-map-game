//
//  AMap3DObjectOverlayRenderer.h
//  reaverInMap
//
//  Created by xiaoming han on 16/8/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "AMap3DObjectOverlay.h"

@protocol AMap3DObjectOverlayRendererDelegate <NSObject>

@optional
- (void)currentOverlayCenterCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface AMap3DObjectOverlayRenderer : MAOverlayRenderer

@property (nonatomic, readonly) AMap3DObjectOverlay *objOverlay;
@property (nonatomic, weak) id <AMap3DObjectOverlayRendererDelegate> customerDelegate;

- (instancetype)initWithObjectOverlay:(AMap3DObjectOverlay *)objOverlay;

- (void)moveToNewCoordinate:(CLLocationCoordinate2D)coordinate andDuration:(NSTimeInterval)duration;

@end



