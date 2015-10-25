#import "GameViewController.h"
#import "IcosahedronModel.h"
#import "Mesh-Swift.h"
@import OpenGLES;
@import SpriteKit;

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet SKView *infoView;
@property (nonatomic) GameScene *gameScene;
@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKBaseEffect *effect;
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
    GLuint _vertexBufferID;
    GLKMatrix4 _modelViewMatrix;
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

    [self setUpGL];

    self.icosahedronModel = [IcosahedronModel new];

    self.currentVertex = self.icosahedronModel.vertexDict[@"C"];
    self.animationProgress = 1.0;
    self.prevQuaternion = GLKQuaternionIdentity;
    self.currentQuaternion = GLKQuaternionIdentity;

    [self setUpInfoView];

    [self.gameScene updateInfo:self.currentVertex];
}

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];

    self.effect = [GLKBaseEffect new];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.effect.colorMaterialEnabled = GL_TRUE;

    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    float width = 1.0;
    float height = width / aspect;
    self.effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-width / 2, width / 2, -height / 2, height / 2, 0.1, 100);

    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &_vertexBufferID);

    glDeleteProgram(_program);
    _program = 0;

    self.context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)setUpInfoView
{
    self.gameScene = [GameScene sceneWithSize:self.view.bounds.size];
    [self.infoView presentScene:self.gameScene];
}

- (void)update
{
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);

    if (self.animationProgress < 1.0) {
        self.animationProgress += self.timeSinceLastUpdate;
        self.animationProgress = MIN(1.0, self.animationProgress);
    }

    GLKQuaternion modelQuaternion = GLKQuaternionSlerp(self.prevQuaternion, self.currentQuaternion, self.animationProgress);

    _modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 0.0);
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, GLKMathDegreesToRadians(180), 0.0, 0.0, 1.0);
    _modelViewMatrix = GLKMatrix4Rotate(_modelViewMatrix, GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0);
    _modelViewMatrix = GLKMatrix4Multiply(_modelViewMatrix, GLKMatrix4MakeWithQuaternion(modelQuaternion));
    _modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, _modelViewMatrix);
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

    float radian = atan2f(-location.y, location.x);
    radian = radian > 0 ? radian : radian + 2 * M_PI;

    [self moveNextVertex:radian];
}

- (void)moveNextVertex:(float)theta
{
    self.prevVertex = self.currentVertex;

    float unit = 2 * M_PI / 5;
    if (0 < theta && theta <= unit) {
        self.currentVertex = self.prevVertex.head;
    } else if (unit < theta && theta <= unit * 2) {
        self.currentVertex = self.prevVertex.leftHand;
    } else if (unit * 2 < theta && theta <= unit * 3) {
        self.currentVertex = self.prevVertex.leftFoot;
    } else if (unit * 3 < theta && theta <= unit * 4) {
        self.currentVertex = self.prevVertex.rightFoot;
    } else {
        self.currentVertex = self.prevVertex.rightHand;
    }
    self.animationProgress = 0.0;

    self.prevQuaternion = self.currentQuaternion;
    GLKQuaternion relativeQuaternion = [self quaternionForRotateFrom:self.currentVertex.coordinate to:self.prevVertex.coordinate];
    self.currentQuaternion = GLKQuaternionMultiply(self.currentQuaternion, relativeQuaternion);

    [self.gameScene updateInfo:self.currentVertex];
}

#pragma mark - GLKViewDelegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);

    self.effect.transform.modelviewMatrix = _modelViewMatrix;
    [self.effect prepareToDraw];

    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * IcosahedronModelNumberOfFaceVertices, self.icosahedronModel.vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));

    glDrawArrays(GL_TRIANGLES, 0, IcosahedronModelNumberOfFaceVertices);
}

@end
