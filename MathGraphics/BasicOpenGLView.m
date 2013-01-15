//
//  BasicOpenGLView.m
//  MathGraphics
//
//  Created by Ryan Hoegg on 6/9/12.
//  Copyright (c) 2012 Brightdome. All rights reserved.
//

#import "BasicOpenGLView.h"

const float PI_OVER_3 = M_PI / 3;
    
const Vertex coloredVertices[] = {
    {{0.5, 0, -0.4330127}, {1, 0, 0, 1}},
    {{-0.5, 0, -0.4330127}, {0, 1, 0, 1}},
    {{0, 0, 0.4330127}, {0, 0, 1, 1}},
    {{0, 0.75, 0}, {0, 0, 0, 1}}
};

const Vertex whiteVertices[] = {
    {{0.5, 0, -0.4330127}, {1, 1, 1, 1}},
    {{-0.5, 0, -0.4330127}, {1, 1, 1, 1}},
    {{0, 0, 0.4330127}, {1, 1, 1, 1}},
    {{0, 0.75, 0}, {1, 1, 1, 1}}
};

// 0 - (cos(pi/3) == 1/2, 0, -1/2 sin(pi/3))
// 1 - (-cos(pi/3) == -1/2, 0, -1/2 sin(pi/3))
// 2 - (0, 0, 1/2 sin(pi/3))
// 3 - (0, sin^2(pi/3) == 3/4, 0)
    
const GLubyte indices[] = {
    0, 3, 2,
    3, 2, 1,
    0, 2, 1,
    0, 1, 3
};

@implementation BasicOpenGLView

+(Class) layerClass {
    return [CAEAGLLayer class];
}
-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initGraphics];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initGraphics];
    }
    return self;
}

-(void) initGraphics {
    [self setupLayer];
    [self setupContext];
    [self setupDepthBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffers];
    [self compileShaders];
    [self setupVertexBufferObjects];
    [self setupDisplayLink]; 

}

- (void) dealloc {
    [_context release];
    _context = nil;
    [super dealloc];
}

- (void) setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void) setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    
    if (_context) {
        if (![EAGLContext setCurrentContext:_context]) {
            NSLog(@"Failed to set current OpenGL context");
            _glError = YES;
        }    
    } else {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        _glError = YES;
    }
}

- (void) setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void) setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void) setupFrameBuffers {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void) setupVertexBufferObjects {
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(coloredVertices), coloredVertices, GL_STATIC_DRAW);

    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
}

- (void) setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) logMatrix:(GLKMatrix4) matrix {
    NSLog(@"| %2.2f %2.2f %2.2f %2.2f |", matrix.m00, matrix.m10, matrix.m20, matrix.m30);
    NSLog(@"| %2.2f %2.2f %2.2f %2.2f |", matrix.m01, matrix.m11, matrix.m21, matrix.m31);
    NSLog(@"| %2.2f %2.2f %2.2f %2.2f |", matrix.m02, matrix.m12, matrix.m22, matrix.m32);
    NSLog(@"| %2.2f %2.2f %2.2f %2.2f |", matrix.m03, matrix.m13, matrix.m23, matrix.m33);
}

- (void) render:(CADisplayLink *)displayLink {
    //NSLog(@"Rendering...");
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *) sizeof(GLKVector4));
    
    GLKMatrix4 modelTransformation = GLKMatrix4MakeTranslation(sin(CACurrentMediaTime()), 0, -7 + sin(CACurrentMediaTime() * 4)); // fixed translate away along z
    modelTransformation = GLKMatrix4Multiply(modelTransformation, GLKMatrix4MakeYRotation(sin(CACurrentMediaTime()) * M_PI / 4)); // animate rotate along y
    modelTransformation = GLKMatrix4Multiply(modelTransformation, GLKMatrix4MakeXRotation(CACurrentMediaTime())); // animate rotate along x
    GLKMatrix4 perspectiveTransformation = GLKMatrix4MakePerspective(M_PI / 4, self.frame.size.width / self.frame.size.height, 1, 30);
    
    //mvpMatrix = GLKMatrix4Make(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    //NSLog(@"translate matrix:");
    //[self logMatrix:modelTranslationTransformation];
    //NSLog(@"perspective matrix:");
    //[self logMatrix:perspectiveTransformation];

    glUniformMatrix4fv(_modelviewUniform, 1, GL_FALSE, modelTransformation.m);
    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, perspectiveTransformation.m);

    glBufferData(GL_ARRAY_BUFFER, sizeof(coloredVertices), coloredVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);

    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(whiteVertices), whiteVertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);

    glDrawElements(GL_LINE_STRIP, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint) compileShader:(NSString *)shaderName withType:(GLenum)shaderType {
    NSString *sourceFileType;
    switch (shaderType) {
        case GL_VERTEX_SHADER:
            sourceFileType = @"vsh";
            break;
        case GL_FRAGMENT_SHADER:
            sourceFileType = @"fsh";
            break;
        default:
            NSLog(@"Can't load shader source because the shader type %d is unrecognized", shaderType);
            return -1;
    }
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:sourceFileType];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        return -1;
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        return -1;
    }
    return shaderHandle;
}

- (void) compileShaders {
    GLuint vertexShader = [self compileShader:@"Basic" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"Basic" withType: GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        return;
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "position");
    _colorSlot = glGetAttribLocation(programHandle, "sourceColor");
    
    _projectionUniform = glGetUniformLocation(programHandle, "projection");
    _modelviewUniform = glGetUniformLocation(programHandle, "modelview");
}

@end
