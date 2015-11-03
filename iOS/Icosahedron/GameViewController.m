@import OpenGLES;
@import SpriteKit;

#import "GameViewController.h"
#import "Icosahedron-Swift.h"
#import "IcosahedronModel.h"
#import "RenderUtils.h"

NS_ENUM(NSUInteger, Uniforms) {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS,
};
GLint uniforms[NUM_UNIFORMS];

NS_ENUM(NSUInteger, VertexArrays) {
    VERTEX_ARRAY_ICOSAHEDRON_POINTS,
    VERTEX_ARRAY_ICOSAHEDRON_LINES,
    NUM_VERTEX_ARRAYS,
    VERTEX_ARRAY_ICOSAHEDRON_FACES,
};
GLuint vertexArrays[NUM_VERTEX_ARRAYS];
GLuint icosahedronVBOs[NUM_VERTEX_ARRAYS];

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

    glEnable(GL_DEPTH_TEST);

    glGenVertexArrays(NUM_VERTEX_ARRAYS, vertexArrays);

    [self setUpIcosahedronPoints];
    [self setUpIcosahedronLines];

    glBindVertexArray(0);
}

- (void)setUpShaders
{
    [RenderUtils loadShaders:&_program path:@"Shader"];

    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
}

- (void)setUpIcosahedronPoints
{
    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glGenBuffers(1, &icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glBindBuffer(GL_ARRAY_BUFFER, icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
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
    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glGenBuffers(1, &icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glBindBuffer(GL_ARRAY_BUFFER, icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * IcosahedronModelNumberOfLineVertices, self.icosahedronModel.lineVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(NUM_VERTEX_ARRAYS, icosahedronVBOs);
    glDeleteVertexArrays(NUM_VERTEX_ARRAYS, vertexArrays);

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
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(_program);

    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glLineWidth(8);
    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glBindBuffer(GL_ARRAY_BUFFER, icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_LINES]);
    glDrawArrays(GL_LINES, 0, IcosahedronModelNumberOfLineVertices);

    glBindVertexArray(vertexArrays[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glBindBuffer(GL_ARRAY_BUFFER, icosahedronVBOs[VERTEX_ARRAY_ICOSAHEDRON_POINTS]);
    glDrawArrays(GL_POINTS, 0, IcosahedronModelNumberOfPointVertices);

    glBindVertexArray(0);
}

@end
