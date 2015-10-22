#import "GameViewController.h"
@import OpenGLES;
@import SpriteKit;

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector4 color;
} Vertex;

typedef struct {
    GLKVector3 point0;
    GLKVector3 point1;
    GLKVector3 point2;
    GLKVector3 point3;
    GLKVector3 point4;
} Link;

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet SKView *infoView;

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKBaseEffect *effect;
@property (nonatomic) SKScene *infoDisplayScene;
@property (nonatomic) SKLabelNode *currentPointLabelNode;

@end

@implementation GameViewController
{
    GLuint vertexBufferID;
    Vertex *modelVertices;
    GLKMatrix4 modelViewMatrix;

    Link *icosahedronLinks;
    NSInteger selectedLinkIndex;
    GLKVector3 prevPoint;
    GLKVector3 currentPoint;
    GLKQuaternion prevQuaternion;
    GLKQuaternion currentQuaternion;
    float animationProgress;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &vertexBufferID);

    self.context = nil;

    [EAGLContext setCurrentContext:nil];

    free(modelVertices);
    free(icosahedronLinks);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;

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

    [self setUpInfoDisplay];

    [self createVertices];
}

- (void)setUpInfoDisplay
{
    self.infoView.showsFPS = YES;
    self.infoView.allowsTransparency = YES;

    self.infoDisplayScene = [SKScene sceneWithSize:self.view.bounds.size];
    self.infoDisplayScene.backgroundColor = [UIColor clearColor];

    self.currentPointLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    self.currentPointLabelNode.position = CGPointMake(4, 4);
    self.currentPointLabelNode.fontSize = 16;
    self.currentPointLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    self.currentPointLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    [self.infoDisplayScene addChild:self.currentPointLabelNode];

    [self.infoView presentScene:self.infoDisplayScene];
}

- (void)updateInfoDisplay
{
    self.currentPointLabelNode.text = [NSString stringWithFormat:@"Current: %ld %@", (long)selectedLinkIndex, NSStringFromGLKVector3(currentPoint)];
}

- (void)createVertices
{
    float scale = 0.15;
    float x = (1 + sqrt(5)) / 2;

    GLKVector3 g = GLKVector3MultiplyScalar(GLKVector3Make( x,  0,  1), scale);
    GLKVector3 e = GLKVector3MultiplyScalar(GLKVector3Make( x,  0, -1), scale);
    GLKVector3 h = GLKVector3MultiplyScalar(GLKVector3Make(-x,  0,  1), scale);
    GLKVector3 d = GLKVector3MultiplyScalar(GLKVector3Make(-x,  0, -1), scale);

    GLKVector3 a = GLKVector3MultiplyScalar(GLKVector3Make( 1,  x,  0), scale);
    GLKVector3 b = GLKVector3MultiplyScalar(GLKVector3Make(-1,  x,  0), scale);
    GLKVector3 k = GLKVector3MultiplyScalar(GLKVector3Make( 1, -x,  0), scale);
    GLKVector3 j = GLKVector3MultiplyScalar(GLKVector3Make(-1, -x,  0), scale);

    GLKVector3 f = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  x), scale);
    GLKVector3 l = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  x), scale);
    GLKVector3 c = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1, -x), scale);
    GLKVector3 i = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1, -x), scale);

    GLKVector3 normalACB = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, c), GLKVector3Subtract(c, b)));
    GLKVector3 normalAGE = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, g), GLKVector3Subtract(g, e)));
    GLKVector3 normalAFG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, f), GLKVector3Subtract(f, g)));
    GLKVector3 normalABF = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, b), GLKVector3Subtract(b, f)));
    GLKVector3 normalAEC = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, e), GLKVector3Subtract(e, c)));
    GLKVector3 normalBCD = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, c), GLKVector3Subtract(c, d)));
    GLKVector3 normalBDH = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, d), GLKVector3Subtract(d, h)));
    GLKVector3 normalBHF = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, h), GLKVector3Subtract(h, f)));
    GLKVector3 normalCEI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(c, e), GLKVector3Subtract(e, i)));
    GLKVector3 normalCID = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(c, i), GLKVector3Subtract(i, d)));
    GLKVector3 normalDIJ = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(d, i), GLKVector3Subtract(i, j)));
    GLKVector3 normalDJH = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(d, j), GLKVector3Subtract(j, h)));
    GLKVector3 normalEGK = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(e, g), GLKVector3Subtract(g, k)));
    GLKVector3 normalEKI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(e, k), GLKVector3Subtract(k, i)));
    GLKVector3 normalFHL = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(f, h), GLKVector3Subtract(h, l)));
    GLKVector3 normalFLG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(f, l), GLKVector3Subtract(l, g)));
    GLKVector3 normalGLK = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(g, l), GLKVector3Subtract(l, k)));
    GLKVector3 normalHJL = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(h, j), GLKVector3Subtract(j, l)));
    GLKVector3 normalIKJ = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(i, k), GLKVector3Subtract(k, j)));
    GLKVector3 normalJKL = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(j, k), GLKVector3Subtract(k, l)));

    GLKVector4 color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);

    Vertex vertices[] = {
        {a, normalABF, color}, {b, normalABF, color}, {f, normalABF, color},
        {b, normalBHF, color}, {h, normalBHF, color}, {f, normalBHF, color},
        {f, normalFHL, color}, {h, normalFHL, color}, {l, normalFHL, color},
        {f, normalFLG, color}, {l, normalFLG, color}, {g, normalFLG, color},
        {a, normalAFG, color}, {f, normalAFG, color}, {g, normalAFG, color},

//        {a, normalACB, color}, {c, normalACB, color}, {b, normalACB, color},
        {a, normalACB, GLKVector4Make(1.0, 0.0, 0.0, 1.0)},
        {c, normalACB, GLKVector4Make(0.0, 1.0, 0.0, 1.0)},
        {b, normalACB, GLKVector4Make(0.0, 0.0, 1.0, 1.0)},

        {b, normalBCD, color}, {c, normalBCD, color}, {d, normalBCD, color},
        {b, normalBDH, color}, {d, normalBDH, color}, {h, normalBDH, color},
        {d, normalDJH, color}, {j, normalDJH, color}, {h, normalDJH, color},
        {h, normalHJL, color}, {j, normalHJL, color}, {l, normalHJL, color},
        {j, normalJKL, color}, {k, normalJKL, color}, {l, normalJKL, color},
        {g, normalGLK, color}, {l, normalGLK, color}, {k, normalGLK, color},
        {e, normalEGK, color}, {g, normalEGK, color}, {k, normalEGK, color},
        {a, normalAGE, color}, {g, normalAGE, color}, {e, normalAGE, color},
        {a, normalAEC, color}, {e, normalAEC, color}, {c, normalAEC, color},
        {c, normalCID, color}, {i, normalCID, color}, {d, normalCID, color},
        {d, normalDIJ, color}, {i, normalDIJ, color}, {j, normalDIJ, color},
        {i, normalIKJ, color}, {k, normalIKJ, color}, {j, normalIKJ, color},
        {e, normalEKI, color}, {k, normalEKI, color}, {i, normalEKI, color},
        {c, normalCEI, color}, {e, normalCEI, color}, {i, normalCEI, color},
    };

    modelVertices = malloc(sizeof(vertices));
    memcpy(modelVertices, vertices, sizeof(vertices));

    Link links[] = {
        {b, a, e, i, d},
        {a, c, d, h, f},
        {e, c, b, f, g},
        {g, k, i, c, a},
        {l, k, e, a, f},
        {f, h, j, k, g},
        {h, l, g, a, b},
        {j, l, f, b, d},
        {k, l, h, d, i},
        {i, e, g, l, j},
        {d, c, e, k, j},
        {c, i, j, h, b},
    };

    icosahedronLinks = malloc(sizeof(links));
    memcpy(icosahedronLinks, links, sizeof(links));

    currentPoint = c;
    animationProgress = 1.0;

    prevQuaternion = GLKQuaternionIdentity;
    currentQuaternion = GLKQuaternionIdentity;

    selectedLinkIndex = 0;

    [self updateInfoDisplay];
}

- (void)update
{
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);

    if (animationProgress < 1.0) {
        animationProgress += self.timeSinceLastUpdate;
        animationProgress = MIN(1.0, animationProgress);
    }

    GLKQuaternion modelQuaternion = GLKQuaternionSlerp(prevQuaternion, currentQuaternion, animationProgress);

    modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(180), 0.0, 0.0, 1.0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(150), 1.0, 0.0, 0.0);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(modelQuaternion));
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
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
    prevPoint = currentPoint;

    float unit = 2 * M_PI / 5;
    if (0 < theta && theta <= unit) {
        currentPoint = icosahedronLinks[selectedLinkIndex].point0;
    } else if (unit < theta && theta <= unit * 2) {
        currentPoint = icosahedronLinks[selectedLinkIndex].point1;
    } else if (unit * 2 < theta && theta <= unit * 3) {
        currentPoint = icosahedronLinks[selectedLinkIndex].point2;
    } else if (unit * 3 < theta && theta <= unit * 4) {
        currentPoint = icosahedronLinks[selectedLinkIndex].point3;
    } else {
        currentPoint = icosahedronLinks[selectedLinkIndex].point4;
    }
    animationProgress = 0.0;

    prevQuaternion = currentQuaternion;
    currentQuaternion = GLKQuaternionMultiply(currentQuaternion, [self quaternionForRotateFrom:currentPoint to:prevPoint]);

    selectedLinkIndex++;
    selectedLinkIndex = selectedLinkIndex % 12;

    [self updateInfoDisplay];
}

#pragma mark - GLKViewDelegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);

    self.effect.transform.modelviewMatrix = modelViewMatrix;
    [self.effect prepareToDraw];

    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * 3 * 20, modelVertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));

    glDrawArrays(GL_TRIANGLES, 0, 3 * 20);
}

@end
