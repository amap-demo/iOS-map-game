//
//  StereoOverlayRenderer.h
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "ReaverOverlay.h"

@interface ReaverOverlayRenderer : MAOverlayRenderer

- (instancetype)initWithReaverOverlay:(ReaverOverlay *)ReaverOverlay;

@property (nonatomic, readonly) ReaverOverlay *reaverOverlay;

@end
