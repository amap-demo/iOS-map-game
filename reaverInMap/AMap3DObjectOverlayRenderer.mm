//
//  AMap3DObjectOverlayRenderer.m
//  reaverInMap
//
//  Created by xiaoming han on 16/8/19.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "AMap3DObjectOverlayRenderer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

struct AMap3DObjectVertex {
    float x;
    float y;
    float z;
};
typedef struct AMap3DObjectVertex AMap3DObjectVertex;

@interface AMap3DObjectOverlayRenderer()

@property (nonatomic, assign)BOOL isNeedDoMoveCoordinate;

@end

@implementation AMap3DObjectOverlayRenderer
{
    AMap3DObjectVertex _centerGL;
//    CGFloat            _sizeGL;
//    BOOL               _isNeedDoMoveCoordinate;
    CLLocationCoordinate2D _fromValue;
    CLLocationCoordinate2D _toValue;
    CFTimeInterval _duration;
    CFTimeInterval _elapse;
    CFTimeInterval _currentTime;
    
    float _scale[16];
    
    GLuint _program;
    GLuint _vertexLocation;
    GLuint _indicesLocation;
    GLuint _textureCodeLocation;
    GLuint _rotateLocation;
    
    GLuint _viewMatrixLocation;
    GLuint _projectionMatrixLocation;
    GLuint _scaleMatrixLocation;

}

- (void)setIsNeedDoMoveCoordinate:(BOOL)isNeedDoMoveCoordinate
{
    _isNeedDoMoveCoordinate = isNeedDoMoveCoordinate;
}

- (void)initShader
{
    NSString *vertexShader = @"precision highp float;\n\
    attribute vec3 aVertex;\n\
    attribute vec2 aTextureCoord;\n\
    uniform vec3 aRotate;\n\
    uniform mat4 aViewMatrix;\n\
    uniform mat4 aProjectionMatrix;\n\
    uniform mat4 aTransformMatrix;\n\
    uniform mat4 aScaleMatrix;\n\
    varying vec2 texture;\n\
    mat4 rotationMatrix(vec3 axis, float angle)\n\
    {\n\
        axis = normalize(axis);\n\
        float s = sin(angle);\n\
        float c = cos(angle);\n\
        float oc = 1.0 - c;\n\
        return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,\n\
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,\n\
                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,\n\
                    0.0,                                0.0,                                0.0,                                1.0);\n\
    }\n\
    void main(){\n\
    mat4 rotateMatrix = rotationMatrix(vec3(1,0,0),aRotate.x) * rotationMatrix(vec3(0,1,0),aRotate.y) * rotationMatrix(vec3(0,0,1),aRotate.z);\n\
    gl_Position = aProjectionMatrix * aViewMatrix * rotateMatrix * aScaleMatrix * vec4(aVertex, 1.0);\n\
    texture = aTextureCoord;\n\
    }";
    
    NSString *fragmentShader = @"\n\
    precision highp float;\n\
    varying vec2 texture;\n\
    uniform sampler2D aTextureUnit0;\n\
    void main(){\n\
    gl_FragColor = texture2D(aTextureUnit0, texture);\n\
    }";
    
    
    _program = glCreateProgram();
    
    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    
    GLint vlength = (GLint)[vertexShader length];
    
    GLint flength = (GLint)[fragmentShader length];
    
    
    const GLchar *vByte = [vertexShader UTF8String];
    const GLchar *fByte = [fragmentShader UTF8String];
    
    glShaderSource(vShader, 1, &vByte, &vlength);
    
    glShaderSource(fShader, 1, &fByte, &flength);
    
    
    glCompileShader(vShader);
    
    glCompileShader(fShader);
    
    
    glAttachShader(_program, vShader);
    
    
    glAttachShader(_program, fShader);
    
    
    glLinkProgram(_program);
    
    
    
    _vertexLocation  = glGetAttribLocation(_program, "aVertex");
    
    
    _viewMatrixLocation = glGetUniformLocation(_program,"aViewMatrix");
    
    
    _projectionMatrixLocation = glGetUniformLocation(_program,"aProjectionMatrix");
    
    
    _scaleMatrixLocation = glGetUniformLocation(_program, "aScaleMatrix");
    
    _textureCodeLocation = glGetAttribLocation(_program,"aTextureCoord");
    
    _rotateLocation = glGetUniformLocation(_program, "aRotate");
    
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
    self.isNeedDoMoveCoordinate = YES;
}

- (void)didMoveCoordinate
{
    if (_elapse >= _duration) {

        [self setOverlayCoordinate:_toValue];
        
        self.isNeedDoMoveCoordinate = NO;
        
        return;
    }
    
    CFTimeInterval lastTime = _currentTime;
    _currentTime = CACurrentMediaTime();
    
    
    CGFloat slices = _elapse / _duration;
    
    
    [self setOverlayCoordinate:CLLocationCoordinate2DMake([self linearBySlice:slices start:_fromValue.latitude end:_toValue.latitude],
                                                          [self linearBySlice:slices start:_fromValue.longitude end:_toValue.longitude])];
    
    _elapse += _currentTime - lastTime;
}

- (AMap3DObjectOverlay *)objOverlay
{
    return (AMap3DObjectOverlay *)self.overlay;
}

#pragma mark - Override

- (void)updateOverlayCenter
{
     AMap3DObjectOverlay *objOverlay = self.objOverlay;

    CGPoint centerInGL = [self glPointForMapPoint:MAMapPointForCoordinate(self.overlay.coordinate)];
    _centerGL.x = centerInGL.x;
    _centerGL.y = centerInGL.y;
    _centerGL.z = objOverlay.altitude * MAMapPointsPerMeterAtLatitude(self.overlay.coordinate.latitude);
}

void translateM(float* m, int mOffset,float x, float y, float z) {
    for (int i=0 ; i<4 ; i++) {
        int mi = mOffset + i;
        m[12 + mi] += m[mi] * x + m[4 + mi] * y + m[8 + mi] * z;
    }
}

/* OpenGL绘制。 */
- (void)glRender
{
    [super glRender];
    
    if (_program == 0) {
        [self initShader];
        
        float scale[] = {
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
        };
        
        for (int i = 0; i < 16; i++) {
            _scale[i] = scale[i];
        }
        
        CGFloat scaleValue = [self calculateSizeInGLReference];
        
        _scale[0] = scaleValue;
        _scale[5] = scaleValue;
        _scale[10] = scaleValue;
    }
    
    AMap3DObjectOverlay *objOverlay = self.objOverlay;
    
    if (self.isNeedDoMoveCoordinate) {
        [self didMoveCoordinate];
    }
    
    if (objOverlay.vertsNum == 0)
    {
        return;
    }
    
    glUseProgram(_program);

    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    
    glBindTexture(GL_TEXTURE_2D, self.strokeTextureID);

    glEnableVertexAttribArray(_vertexLocation);
    
    glVertexAttribPointer(_vertexLocation, 3, GL_FLOAT, false, 0, objOverlay.vertexPointer);

    glEnableVertexAttribArray(_textureCodeLocation);

    glVertexAttribPointer(_textureCodeLocation, 2, GL_FLOAT, false, 0, objOverlay.texCoordPointer);


    
    if ([self.objOverlay.textureName isEqualToString:@"FA-22_Raptor_P01.png"] && objOverlay.altitude < 500) {
        _centerGL.z =  [self calculateSizeInGLReference] / objOverlay.size * objOverlay.altitude;
        objOverlay.altitude += 2;
    }
    
    if ([self.objOverlay.textureName isEqualToString:@"FelReaverMount.png"]) {
        objOverlay.angle += 1;
    }
    
    [self updateOverlayCenter];

    
    glUniformMatrix4fv(_scaleMatrixLocation, 1, false, _scale);
    
    glUniform3f(_rotateLocation, - 90.0 * M_PI / 180.0f, -(GLfloat)objOverlay.angle * M_PI / 180.f,0.0f);
    
    float * viewMatrix = [self getViewMatrix];
    
    float viewMatrixCopy[16];
    for (int i = 0; i < 16; i++) {
        viewMatrixCopy[i] = viewMatrix[i];
    }
    
    translateM(viewMatrixCopy, 0, _centerGL.x, _centerGL.y, _centerGL.z);
    
    float * projectionMatrix = [self getProjectionMatrix];
    
    glUniformMatrix4fv(_viewMatrixLocation, 1, false, viewMatrixCopy);
    
    glUniformMatrix4fv(_projectionMatrixLocation, 1, false, projectionMatrix);
    
    glDrawArrays(GL_TRIANGLES, 0, objOverlay.vertsNum);
    
    glDisableVertexAttribArray(_vertexLocation);
    
    glDisableVertexAttribArray(_textureCodeLocation);
    
    glDepthMask(GL_FALSE);
    glDisable(GL_DEPTH_TEST);
    
    glUseProgram(0);
//
//    
//    glDepthFunc(GL_LESS);
//    
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    
//    glEnable(GL_TEXTURE_2D);
//    glEnableClientState(GL_VERTEX_ARRAY);
//    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//    
//    glBindTexture(GL_TEXTURE_2D, self.strokeTextureID);
//    glColor4f(1, 1, 1, 1);
//    
//    glPushMatrix();
//    
//    if ([self.objOverlay.textureName isEqualToString:@"FA-22_Raptor_P01"] && objOverlay.altitude < 500) {
//        _centerGL.z =  [self calculateSizeInGLReference] / objOverlay.size * objOverlay.altitude;
//        objOverlay.altitude += 2;
//    }
//    glTranslatef(_centerGL.x, _centerGL.y, _centerGL.z);
//    glRotatef(90, 1, 0, 0);
//    
//    glRotatef(objOverlay.angle, 0, 1, 0);
//    if ([self.objOverlay.textureName isEqualToString:@"FelReaverMount"]) {
//        objOverlay.angle += 1;
//    }
//    
//    glScalef(_sizeGL, _sizeGL, _sizeGL);
//    
//    glVertexPointer(3, GL_FLOAT, 0, objOverlay.vertexPointer);
//    glNormalPointer(GL_FLOAT, 0, objOverlay.normalPointer);
//    glTexCoordPointer(2, GL_FLOAT, 0, objOverlay.texCoordPointer);
//    
//    glDrawArrays(GL_TRIANGLES, 0, objOverlay.vertsNum);
//    
//    glPopMatrix();
//    
//    glDisable(GL_TEXTURE_2D);
//    glDisableClientState(GL_VERTEX_ARRAY);
//    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//    
//    glDisable(GL_BLEND);
//    glDisable(GL_DEPTH_TEST);
    
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
