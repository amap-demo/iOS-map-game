//
//  StereoOverlayRenderer.m
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//


#import "ReaverOverlayRenderer.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
//#import "FelReaverMount.h"

template <typename T>
struct Vector3 {
    Vector3() {}
    Vector3(T x, T y, T z) : x(x), y(y), z(z) {}
    T x;
    T y;
    T z;
};

typedef Vector3<float> Vertex;

@interface ReaverOverlayRenderer()

@end


@implementation ReaverOverlayRenderer
{
    Vertex     _centerGL;
    CGFloat    _sizeGL;
}

#pragma mark - Interface

- (ReaverOverlay *)reaverOverlay
{
    return (ReaverOverlay *)self.overlay;
}

#pragma mark - Override

/* 计算经纬度坐标对应的OpenGL坐标，每次地图坐标系有变化均会调用这个方法。 */
- (void)referenceDidChange
{
    [super referenceDidChange];

    _sizeGL = [self calculateSizeInGLReference];
    
    CGPoint centerInGL = [self glPointForMapPoint:MAMapPointForCoordinate(self.overlay.coordinate)];
    _centerGL.x = centerInGL.x;
    _centerGL.y = centerInGL.y;
    _centerGL.z = _sizeGL;
}

/* OpenGL绘制。 */
- (void)glRender
{
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
    
    glTranslatef(_centerGL.x, _centerGL.y, _centerGL.z);
    glRotatef(90, 1, 0, 0);
    
    static float rotateZ = 0.0;
    glRotatef(rotateZ, 0, 1, 0);
    rotateZ += 5.0;
    
    glScalef(_sizeGL, _sizeGL, _sizeGL);
    
   // glVertexPointer(3, GL_FLOAT, 0, FelReaverMountVerts);
   // glTexCoordPointer(2, GL_FLOAT, 0, FelReaverMountTexCoords);
    
   // glDrawArrays(GL_TRIANGLES, 0, FelReaverMountNumVerts);

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
    ReaverOverlay * reaverOverlay = self.reaverOverlay;

    MAMapRect bounding = [reaverOverlay boundingMapRect];
    MAMapPoint mapEdge[2];
    mapEdge[0] = bounding.origin;
    mapEdge[1] = MAMapPointMake(bounding.origin.x + bounding.size.width, bounding.origin.y);
    
    CGPoint * glEdge = [self glPointsForMapPoints:mapEdge count:2];
    
    return [self lengthBetweenPointA:glEdge[0] andPointB:glEdge[1]];
}

#pragma mark - Init

- (instancetype)initWithReaverOverlay:(ReaverOverlay *)ReaverOverlay
{
    self = [super initWithOverlay:ReaverOverlay];
    if (self)
    {
    }
    
    return self;
}

- (instancetype)initWithOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[ReaverOverlay class]])
    {
        return nil;
    }
    
    return [self initWithReaverOverlay:overlay];
}

@end
