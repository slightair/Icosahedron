#import "GameViewController.h"
#import "IcosahedronModel.h"
#import "Icosahedron-Swift.h"
@import OpenGLES;
@import SpriteKit;

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS,
};
GLint uniforms[NUM_UNIFORMS];

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
    GLuint _program;

    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;

    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
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

    [self loadShaders];

    glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * IcosahedronModelNumberOfFaceVertices, self.icosahedronModel.vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));

    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);

    glDeleteProgram(_program);
    _program = 0;

    [EAGLContext setCurrentContext:nil];
    self.context = nil;
}

- (void)setUpInfoView
{
    self.gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    [self.infoView presentScene:self.gameScene];
}

- (GLKQuaternion)quaternionForRotateFrom:(GLKVector3)from to:(GLKVector3)to
{
    GLKVector3 normalizedFrom = GLKVector3Normalize(from);
    GLKVector3 normalizedTo = GLKVector3Normalize(to);

    float cosTheta = GLKVector3DotProduct(normalizedFrom, normalizedTo);
    GLKVector3 rotationAxis = GLKVector3CrossProduct(normalizedFrom, normalizedTo);

    float s = sqrtf((1 + cosTheta) * 2);
    float inverse = 1 / s;

    return GLKQuaternionMakeWithVector3(GLKVector3MultiplyScalar(rotationAxis, inverse), s * 0.5);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    location.x -= CGRectGetMidX(self.view.bounds);
    location.y -= CGRectGetMidY(self.view.bounds);

    NSArray *candidates = self.currentVertex.nextVertices;

    GLKVector3 locationVector = GLKVector3Normalize(GLKVector3Make(location.x, location.y, 0));

    float nearestDistance = FLT_MAX;
    IcosahedronVertex *nearestVertex = nil;
    for (IcosahedronVertex *v in candidates) {
        float distance = GLKVector3Distance(locationVector, v.coordinate);
        if (distance < nearestDistance) {
            nearestDistance = distance;
            nearestVertex = v;
        }
        NSLog(@"%@ %f %@", v.name, distance, NSStringFromGLKVector3(v.coordinate));
    }

    NSLog(@">> %@ <<", nearestVertex.name);

    [self moveToVertex:nearestVertex];
}

- (void)moveToVertex:(IcosahedronVertex *)vertex
{
    self.prevVertex = self.currentVertex;
    self.currentVertex = vertex;
    self.animationProgress = 0.0;

    self.prevQuaternion = self.currentQuaternion;
    GLKQuaternion relativeQuaternion = [self quaternionForRotateFrom:self.currentVertex.coordinate to:self.prevVertex.coordinate];
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
        self.animationProgress += self.timeSinceLastUpdate;
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
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glDrawArrays(GL_TRIANGLES, 0, IcosahedronModelNumberOfFaceVertices);
}

#pragma mark - OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    _program = glCreateProgram();

    GLuint vertShader;
    NSString *vertShaderPathName = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathName]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    GLuint fragShader;
    NSString *fragShaderPathName = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathName]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);

    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribColor, "color");

    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }

        return NO;
    }

    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");

    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }

    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }

    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    glValidateProgram(prog);

    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    GLint status;
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}

@end
