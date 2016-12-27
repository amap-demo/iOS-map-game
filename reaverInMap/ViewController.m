//
//  ViewController.m
//  reaverInMap
//
//  Created by yi chen on 1/26/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

#import "AMap3DObjectOverlayRenderer.h"
#import "FelReaverMount.h"
#import "Farmhouse OBJ.h"
#import "Snow covered CottageOBJ.h"
#import "Combat_Vehicle.h"
#import "raptor.h"


@interface ViewController ()<MAMapViewDelegate, UIGestureRecognizerDelegate,AMap3DObjectOverlayRendererDelegate>

@property (nonatomic, strong) MAMapView * mapView;

@property (nonatomic, strong) AMap3DObjectOverlay *airPlaneOverlay;

@property (nonatomic, strong) AMap3DObjectOverlay *carOverlay;

@property (nonatomic, strong) AMap3DObjectOverlay *monsterOverlay;

@property (nonatomic, strong) AMap3DObjectOverlay *house1;

@property (nonatomic, strong) AMap3DObjectOverlay *house2;

@end

@implementation ViewController

#pragma mark - overlay delegate

- (void)currentOverlayCenterCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapView setCenterCoordinate:coordinate animated:NO];
}

#pragma mark - map delegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[AMap3DObjectOverlay class]])
    {
        AMap3DObjectOverlay *objOverlay = (AMap3DObjectOverlay *)overlay;
        AMap3DObjectOverlayRenderer * reaverRenderer = [[AMap3DObjectOverlayRenderer alloc] initWithObjectOverlay:overlay];
        [reaverRenderer loadStrokeTextureImage:[UIImage imageNamed:objOverlay.textureName]];
        return reaverRenderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers
{
    [self performSelector:@selector(action1) withObject:nil afterDelay:0.5];
    
    [self performSelector:@selector(action2) withObject:nil afterDelay:0.5 + 3];
}


#pragma mark - action
- (void)action1
{
    [self.mapView setZoomLevel:17 animated:YES];
    [self.mapView setCenterCoordinate:self.airPlaneOverlay.coordinate animated:YES];
    [self.mapView setCameraDegree:60 animated:YES duration:1];

    AMap3DObjectOverlayRenderer *render = (AMap3DObjectOverlayRenderer *)[self.mapView rendererForOverlay:self.airPlaneOverlay];
    
    render.customerDelegate = self;
    [render moveToNewCoordinate:CLLocationCoordinate2DMake(39.995001, 116.480644) andDuration:3];
}

- (void)action2
{
    
    [self.mapView setZoomLevel:19 animated:YES];
    [self.mapView setRotationDegree:40 animated:YES duration:1];
    [self.mapView setCameraDegree:60 animated:YES duration:1];
    [self.mapView setCenterCoordinate:self.carOverlay.coordinate animated:YES];

    AMap3DObjectOverlayRenderer *render = (AMap3DObjectOverlayRenderer *)[self.mapView rendererForOverlay:self.carOverlay];
    
    render.customerDelegate = self;
    [render moveToNewCoordinate:CLLocationCoordinate2DMake(39.99537, 116.477174) andDuration:8];
}

#pragma mark - overlay init

- (void)houseInit
{
    self.house1 = [AMap3DObjectOverlay objectOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.993266, 116.473269)
                                                                    size:150
                                                           vertexPointer:Snow_covered_CottageOBJVerts
                                                           normalPointer:Snow_covered_CottageOBJNormals
                                                         texCoordPointer:Snow_covered_CottageOBJTexCoords
                                                                vertsNum:Snow_covered_CottageOBJNumVerts];
    
    self.house1.angle = 315;
    self.house1.altitude = 5;
    self.house1.textureName = @"Cottage Texture";
    
    [self.mapView addOverlay:self.house1];
    
    
    self.house2 = [AMap3DObjectOverlay objectOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.994794, 116.47762)
                                                                    size:150
                                                           vertexPointer:Farmhouse_OBJVerts
                                                           normalPointer:Farmhouse_OBJNormals
                                                         texCoordPointer:Farmhouse_OBJTexCoords
                                                                vertsNum:Farmhouse_OBJNumVerts];
    
    self.house2.angle = 40;
    self.house2.altitude = 5;
    self.house2.textureName = @"Farmhouse Texture";
    
    [self.mapView addOverlay:self.house2];


}

- (void)monsterInit
{
    self.monsterOverlay = [AMap3DObjectOverlay objectOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.996965, 116.478548)
                                                                            size:300
                                                                   vertexPointer:FelReaverMountVerts
                                                                   normalPointer:FelReaverMountNormals
                                                                 texCoordPointer:FelReaverMountTexCoords
                                                                        vertsNum:FelReaverMountNumVerts];
    
    self.monsterOverlay.angle = 200;
    self.monsterOverlay.altitude = 130;
    self.monsterOverlay.textureName = @"FelReaverMount";
    
    [self.mapView addOverlay:self.monsterOverlay];
}

- (void)carInit
{
    self.carOverlay = [AMap3DObjectOverlay objectOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.991289, 116.472575)
                                                                 size:35
                                                        vertexPointer:Combat_VehicleVerts
                                                        normalPointer:Combat_VehicleNormals
                                                      texCoordPointer:Combat_VehicleTexCoords
                                                             vertsNum:Combat_VehicleNumVerts];
    self.carOverlay.angle = 40;
    self.carOverlay.altitude = 4;
    self.carOverlay.textureName = @"V_body";
    
    [self.mapView addOverlay:self.carOverlay];
    
}

- (void)airPlaneInit
{
    self.airPlaneOverlay = [AMap3DObjectOverlay objectOverlayWithCenterCoordinate:CLLocationCoordinate2DMake(39.984479, 116.494635)
                                                                             size:100
                                                                    vertexPointer:raptorVerts
                                                                    normalPointer:raptorNormals
                                                                  texCoordPointer:raptorTexCoords
                                                                         vertsNum:raptorNumVerts];
    self.airPlaneOverlay.angle = 128;
    self.airPlaneOverlay.altitude = 10;
    self.airPlaneOverlay.textureName = @"FA-22_Raptor_P01";
    
    [self.mapView addOverlay:self.airPlaneOverlay];
}



#pragma mark - override

- (MAMapView *)mapView
{
    if (_mapView == nil)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(39.991647, 116.475237);
        _mapView.zoomLevel = 15.0;
        _mapView.isAllowDecreaseFrame = NO;
        _mapView.showsBuildings = NO;
        _mapView.showsLabels = NO;
        _mapView.mapType = MAMapTypeNavi;
    }

    return _mapView;
}

#pragma mark - life cycle

- (void)viewDidAppear:(BOOL)animated {
    [self airPlaneInit];
    [self carInit];
    [self monsterInit];
    [self houseInit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up mapView
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    
}

@end
