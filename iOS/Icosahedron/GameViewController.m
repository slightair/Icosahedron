@import OpenGLES;
@import SpriteKit;

#import "GameViewController.h"
#import "Icosahedron-Swift.h"
#import "IcosahedronModel.h"
#import "RenderUtils.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

NS_ENUM(NSUInteger, Programs) {
    PROGRAM_MODEL,
    PROGRAM_BLUR,
    NUM_PROGRAMS,
};
GLuint programs[NUM_PROGRAMS];

NS_ENUM(NSUInteger, ModelShaderUniforms) {
    MODEL_SHADER_UNIFORM_MODELVIEWPROJECTION_MATRIX,
    MODEL_SHADER_UNIFORM_NORMAL_MATRIX,
    NUM_MODEL_SHADER_UNIFORMS,
};
GLint modelShaderUniforms[NUM_MODEL_SHADER_UNIFORMS];

NS_ENUM(NSUInteger, BlurShaderUniforms) {
    BLUR_SHADER_UNIFORM_SOURCE_TEXTURE,
    BLUR_SHADER_UNIFORM_TEXEL_SIZE,
    BLUR_SHADER_UNIFORM_USE_BLUR,
    NUM_BLUR_SHADER_UNIFORMS,
};
GLint blurShaderUniforms[NUM_BLUR_SHADER_UNIFORMS];

NS_ENUM(NSUInteger, VertexArrays) {
    VERTEX_ARRAY_ICOSAHEDRON_POINTS,
    VERTEX_ARRAY_ICOSAHEDRON_LINES,
    VERTEX_ARRAY_CANVAS,
    NUM_VERTEX_ARRAYS,
};
GLuint vertexArrays[NUM_VERTEX_ARRAYS];
GLuint vertexBufferObjects[NUM_VERTEX_ARRAYS];

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet SKView *infoView;
@property (nonatomic) GameScene *gameScene;
@property (nonatomic) EAGLContext *context;
@property (nonatomic) IcosahedronModel *icosahedronModel;
@property (nonatomic) IcosahedronVertex *prevVertex;
@property (nonatomic) IcosahedronVertex *currentVertex;
@property (nonatomic) GLKQuaternion prevQuaternion;
@property (nonatomic) GLKQuaternion currentQuaternion;
@property (nonatomic) float animationProgress;

@end

@implementation GameViewController
{
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;

    GLuint _modelFrameBufferObject;
    GLuint _modelColorTexture;
    GLuint _modelDepthRenderBufferObject;

    GLKVector2 _texelSize;
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatSRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    self.icosahedronModel = [IcosahedronModel new];

    self.currentVertex = self.icosahedronModel.vertexDict[@"C"];
    self.animationProgress = 1.0;
    self.prevQuaternion = GLKQuaternionIdentity;
    self.currentQuaternion = GLKQuaternionIdentity;

    [self setUpGL];
    [self setUpInfoView];

    [self.gameScene updateInfo:self.currentVertex];
}

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];

    [self setUpShaders];

    glGenVertexArrays(NUM_VERTEX_ARRAYS, vertexArrays);

    [self setUpIcosahedronPoints];
    [self setUpIcosahedronLines];
    [self setUpCanvas];

    glBindVertexArray(0);

    float width = CGRectGetHeight([UIScreen mainScreen].nativeBounds);
    float height = CGRectGetWidth([UIScreen mainScreen].nativeBounds);
    _texelSize = GLKVector2Make(1.0 / width, 1.0 / height);

    glGenTextures(1, &_modelColorTexture);
    glBindTexture(GL_TEXTURE_2D, _modelColorTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glBindTexture(GL_TEXTURE_2D, 0);

    glGenRenderbuffers(1, &_modelDepthRenderBufferObject);
    glBindRenderbuffer(GL_RENDERBUFFER, _modelDepthRenderBufferObject);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, width, height);

    glBindRenderbuffer(GL_RENDERBUFFER, 0);

    glGenFramebuffers(1, &_modelFrameBufferObject);
    glBindFramebuffer(GL_FRAMEBUFFER, _modelFrameBufferObject);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _modelColorTexture, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _modelDepthRenderBufferObject);
    NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Check frame buffer status error!");

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)setUpShaders
{
    [RenderUtils loadShaders:&programs[PROGRAM_MODEL] path:@"ModelShader"];
    modelShaderUniforms[MODEL_SHADER_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programs[PROGRAM_MODEL], "modelViewProjectionMatrix");
    modelShaderUniforms[MODEL_SHADER_UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programs[PROGRAM_MODEL], "normalMatrix");

    [RenderUtils loadShaders:&programs[PROGRAM_BLUR] path:@"BlurShader"];
    blurShaderUniforms[BLUR_SHADER_UNIFORM_SOURCE_TEXTURE] = glGetUniformLocation(programs[PROGRAM_BLUR], "sourceTexture");
    blurShaderUniforms[BLUR_SHADER_UNIFORM_TEXEL_SIZE] = glGetUniformLocation(programs[PROGRAM_BLUR], "texelSize");
    blurShaderUniforms[BLUR_SHADER_UNIFORM_USE_BLUR] = glGetUniformLocation(programs[PROGRAM_BLUR], "useBlur");
}

- (void)setUpIcosahedronPoints
{
    NSUInteger arrayID = VERTEX_ARRAY_ICOSAHEDRON_POINTS;
    glBindVertexArray(vertexArrays[arrayID]);
    glGenBuffers(1, &vertexBufferObjects[arrayID]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[arrayID]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * IcosahedronModelNumberOfPointVertices, self.icosahedronModel.pointVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));
}

- (void)setUpIcosahedronLines
{
    NSUInteger arrayID = VERTEX_ARRAY_ICOSAHEDRON_LINES;
    glBindVertexArray(vertexArrays[arrayID]);
    glGenBuffers(1, &vertexBufferObjects[arrayID]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[arrayID]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * IcosahedronModelNumberOfLineVertices, self.icosahedronModel.lineVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));
}

- (void)setUpCanvas
{
    const float verticies[] = {
        -1.0, -1.0, 0.0, 0.0, 1.0, 1.0, 1.0,
        -1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
         1.0, -1.0, 0.0, 0.0, 1.0, 1.0, 1.0,
         1.0,  1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
    };

    NSUInteger arrayID = VERTEX_ARRAY_CANVAS;
    glBindVertexArray(vertexArrays[arrayID]);
    glGenBuffers(1, &vertexBufferObjects[arrayID]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[arrayID]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verticies), verticies, GL_STATIC_DRAW);

    GLsizei stride = sizeof(float) * 7;
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(0));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(float) * 3));
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(NUM_VERTEX_ARRAYS, vertexBufferObjects);
    glDeleteVertexArrays(NUM_VERTEX_ARRAYS, vertexArrays);

    glDeleteTextures(1, &_modelColorTexture);
    glDeleteRenderbuffers(1, &_modelDepthRenderBufferObject);
    glDeleteFramebuffers(1, &_modelFrameBufferObject);

    glDeleteProgram(programs[PROGRAM_MODEL]);
    glDeleteProgram(programs[PROGRAM_BLUR]);

    [EAGLContext setCurrentContext:nil];
    self.context = nil;
}

- (void)setUpInfoView
{
    self.gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    [self.infoView presentScene:self.gameScene];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    location.x -= CGRectGetMidX(self.view.bounds);
    location.y -= CGRectGetMidY(self.view.bounds);

    GLKVector3 locationVector = GLKVector3Make(location.x * 2 / CGRectGetWidth(self.view.bounds),
                                               -location.y * 2 / CGRectGetHeight(self.view.bounds),
                                               0);
    locationVector = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_modelViewProjectionMatrix, NULL), locationVector);

    float nearestDistance = FLT_MAX;
    IcosahedronVertex *nearestVertex = nil;
    for (IcosahedronVertex *vertex in self.currentVertex.nextVertices) {
        float distance = GLKVector3Distance(locationVector, vertex.coordinate);
        if (distance < nearestDistance) {
            nearestDistance = distance;
            nearestVertex = vertex;
        }
    }

    [self moveToVertex:nearestVertex];
}

- (void)moveToVertex:(IcosahedronVertex *)vertex
{
    self.prevVertex = self.currentVertex;
    self.currentVertex = vertex;
    self.animationProgress = 0.0;

    self.prevQuaternion = self.currentQuaternion;
    GLKQuaternion relativeQuaternion = quaternionForRotate(self.currentVertex, self.prevVertex);
    self.currentQuaternion = GLKQuaternionMultiply(self.currentQuaternion, relativeQuaternion);

    [self.gameScene updateInfo:self.currentVertex];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    float width = 1.0;
    float height = width / aspect;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-width / 2, width / 2, -height / 2, height / 2, 0.1, 100);

    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);

    if (self.animationProgress < 1.0) {
        self.animationProgress += self.timeSinceLastUpdate * 2;
        self.animationProgress = MIN(1.0, self.animationProgress);
    }

    GLKQuaternion modelQuaternion = GLKQuaternionSlerp(self.prevQuaternion, self.currentQuaternion, self.animationProgress);

    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(modelQuaternion));
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLint defaultFrameBufferObject;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFrameBufferObject);

    glBindFramebuffer(GL_FRAMEBUFFER, _modelFrameBufferObject);

    glEnable(GL_DEPTH_TEST);

    GLenum buffers[] = {
        GL_COLOR_ATTACHMENT0,
    };
    glDrawBuffers(1, buffers);

    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(programs[PROGRAM_MODEL]);

    glUniformMatrix4fv(modelShaderUniforms[MODEL_SHADER_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(modelShaderUniforms[MODEL_SHADER_UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glLineWidth(8);
    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glDrawArrays(GL_LINES, 0, IcosahedronModelNumberOfLineVertices);

    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glDrawArrays(GL_POINTS, 0, IcosahedronModelNumberOfPointVertices);

    glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBufferObject);

    glDisable(GL_DEPTH_TEST);

    glUseProgram(programs[PROGRAM_BLUR]);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _modelColorTexture);
    glUniform1i(blurShaderUniforms[BLUR_SHADER_UNIFORM_SOURCE_TEXTURE], 0);
    glUniform2fv(blurShaderUniforms[BLUR_SHADER_UNIFORM_TEXEL_SIZE], 1, _texelSize.v);
    glUniform1i(blurShaderUniforms[BLUR_SHADER_UNIFORM_USE_BLUR], GL_TRUE);

    glBindVertexArray(vertexArrays[VERTEX_ARRAY_CANVAS]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObjects[VERTEX_ARRAY_CANVAS]);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glBindVertexArray(0);
}

@end
