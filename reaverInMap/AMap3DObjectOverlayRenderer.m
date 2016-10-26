//
//  AMap3DObjectOverlayRenderer.m
//  reaverInMap
//
//  Created by xiaoming han on 16/8/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "AMap3DObjectOverlayRenderer.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

struct AMap3DObjectVertex {
    float x;
    float y;
    float z;
};
typedef struct AMap3DObjectVertex AMap3DObjectVertex;

@implementation AMap3DObjectOverlayRenderer
{
    AMap3DObjectVertex _centerGL;
    CGFloat            _sizeGL;
    BOOL               _isNeedDoMoveCoordinate;
    CLLocationCoordinate2D _fromValue;
    CLLocationCoordinate2D _toValue;
    CFTimeInterval _duration;
    CFTimeInterval _elapse;
    CFTimeInterval _currentTime;
}

#pragma mark - Interface

- (double)linearBySlice:(double)slice start:(double)start end:(double)end
{
    double t = slice;
    
    return start + t * (end - start);
}

- (void)setOverlayCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.objOverlay.coordinate = coordinate;
    if (self.customerDelegate != nil && [self.customerDelegate respondsToSelector:@selector(currentOverlayCenterCoordinate:)]) {
        [self.customerDelegate currentOverlayCenterCoordinate:self.objOverlay.coordinate];
    }
    
}

- (void)moveToNewCoordinate:(CLLocationCoordinate2D)coordinate andDuration:(NSTimeInterval)duration
{
    _fromValue = self.objOverlay.coordinate;
    _toValue = coordinate;
    _duration = duration;
    _elapse = 0;
    _currentTime = CACurrentMediaTime();
    _isNeedDoMoveCoordinate = YES;
}

- (void)didMoveCoordinate
{
    if (_elapse >= _duration) {

        [self setOverlayCoordinate:_toValue];
        
        _isNeedDoMoveCoordinate = NO;
        
        [self referenceDidChange];

        
        return;
    }
    
    CFTimeInterval lastTime = _currentTime;
    _currentTime = CACurrentMediaTime();
    
    
    CGFloat slices = _elapse / _duration;
    
    
    [self setOverlayCoordinate:CLLocationCoordinate2DMake([self linearBySlice:slices start:_fromValue.latitude end:_toValue.latitude],
                                                          [self linearBySlice:slices start:_fromValue.longitude end:_toValue.longitude])];
    
    _elapse += _currentTime - lastTime;
    
    [self referenceDidChange];


}

- (AMap3DObjectOverlay *)objOverlay
{
    return (AMap3DObjectOverlay *)self.overlay;
}

#pragma mark - Override

/* 计算经纬度坐标对应的OpenGL坐标，每次地图坐标系有变化均会调用这个方法。 */
- (void)referenceDidChange
{
    [super referenceDidChange];
     AMap3DObjectOverlay *objOverlay = self.objOverlay;
    _sizeGL = [self calculateSizeInGLReference];
    
    CGPoint centerInGL = [self glPointForMapPoint:MAMapPointForCoordinate(self.overlay.coordinate)];
    _centerGL.x = centerInGL.x;
    _centerGL.y = centerInGL.y;
    _centerGL.z = _sizeGL / objOverlay.size * objOverlay.altitude;
}

/* OpenGL绘制。 */
- (void)glRender
{
    AMap3DObjectOverlay *objOverlay = self.objOverlay;
    
    if (_isNeedDoMoveCoordinate) {
        [self didMoveCoordinate];
    }
    
    if (objOverlay.vertsNum == 0)
    {
        return;
    }
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, self.strokeTextureID);
    glColor4f(1, 1, 1, 1);
    
    glPushMatrix();
    
    if ([self.objOverlay.textureName isEqualToString:@"FA-22_Raptor_P01"] && objOverlay.altitude < 500) {
        _centerGL.z =  [self calculateSizeInGLReference] / objOverlay.size * objOverlay.altitude;
        objOverlay.altitude += 2;
    }
    glTranslatef(_centerGL.x, _centerGL.y, _centerGL.z);
    glRotatef(90, 1, 0, 0);
    
    glRotatef(objOverlay.angle, 0, 1, 0);
    if ([self.objOverlay.textureName isEqualToString:@"FelReaverMount"]) {
        objOverlay.angle += 1;
    }
    
    glScalef(_sizeGL, _sizeGL, _sizeGL);
    
    glVertexPointer(3, GL_FLOAT, 0, objOverlay.vertexPointer);
    glNormalPointer(GL_FLOAT, 0, objOverlay.normalPointer);
    glTexCoordPointer(2, GL_FLOAT, 0, objOverlay.texCoordPointer);
    
    glDrawArrays(GL_TRIANGLES, 0, objOverlay.vertsNum);
    
    glPopMatrix();
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    
}

#pragma mark - Helper

- (CGFloat)lengthBetweenPointA:(CGPoint)a andPointB:(CGPoint)b
{
    CGFloat deltaX = a.x - b.x;
    CGFloat deltaY = a.y - b.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}

- (CGFloat)calculateSizeInGLReference
{
    AMap3DObjectOverlay *objOverlay = self.objOverlay;
    
    MAMapRect bounding = [objOverlay boundingMapRect];
    MAMapPoint mapEdge[2];
    mapEdge[0] = bounding.origin;
    mapEdge[1] = MAMapPointMake(bounding.origin.x + bounding.size.width, bounding.origin.y);
    
    CGPoint * glEdge = [self glPointsForMapPoints:mapEdge count:2];
    
    return [self lengthBetweenPointA:glEdge[0] andPointB:glEdge[1]];
}

#pragma mark - Init

- (instancetype)initWithObjectOverlay:(AMap3DObjectOverlay *)objOverlay
{
    self = [super initWithOverlay:objOverlay];
    if (self)
    {
        
    }
    return self;
}

- (instancetype)initWithOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[AMap3DObjectOverlay class]])
    {
        return nil;
    }
    
    return [self initWithObjectOverlay:overlay];
}

@end
