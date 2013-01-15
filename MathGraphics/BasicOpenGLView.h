//
//  BasicOpenGLView.h
//  MathGraphics
//
//  Created by Ryan Hoegg on 6/9/12.
//  Copyright (c) 2012 Brightdome. All rights reserved.
//

// TODO: Add camera projection http://www.songho.ca/opengl/gl_projectionmatrix.html

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKMath.h>

typedef struct {
    GLKVector3 position;
    GLKVector4 color;
} Vertex;

@interface BasicOpenGLView : UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    BOOL _glError;
    
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelviewUniform;
    GLuint _depthRenderBuffer;
    
    GLubyte* _indices;
}

@end
