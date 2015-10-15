#import "GameViewController.h"
@import OpenGLES;
@import UIKit;

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector4 color;
} Vertex;

@interface GameViewController ()

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKBaseEffect *effect;

@end

@implementation GameViewController
{
    GLuint vertexBufferID;
    Vertex *vertices;

    GLKMatrix4 modelViewMatrix;
    float rotation;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &vertexBufferID);

    self.context = nil;

    [EAGLContext setCurrentContext:nil];

    free(vertices);
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

    glEnable(GL_DEPTH_TEST);

    [self createVertices];
}

- (void)createVertices
{
    float scale = 0.5;
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

    int numColors = 20;
    GLKVector4 *colors = malloc(sizeof(GLKVector4) * numColors);
    for(int i = 0; i < numColors; i++) {
        double theta = 1.0 / numColors * i;
        UIColor *color = [UIColor colorWithHue:theta saturation:0.5 brightness:1.0 alpha:1.0];
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        colors[i] = GLKVector4Make(red, green, blue, alpha);
    }

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

    Vertex icosahedron[] = {
        {a, normalABF, colors[0]}, {b, normalABF, colors[0]}, {f, normalABF, colors[0]},
        {b, normalBHF, colors[1]}, {h, normalBHF, colors[1]}, {f, normalBHF, colors[1]},
        {f, normalFHL, colors[2]}, {h, normalFHL, colors[2]}, {l, normalFHL, colors[2]},
        {f, normalFLG, colors[3]}, {l, normalFLG, colors[3]}, {g, normalFLG, colors[3]},
        {a, normalAFG, colors[4]}, {f, normalAFG, colors[4]}, {g, normalAFG, colors[4]},
        {a, normalACB, colors[5]}, {c, normalACB, colors[5]}, {b, normalACB, colors[5]},
        {b, normalBCD, colors[6]}, {c, normalBCD, colors[6]}, {d, normalBCD, colors[6]},
        {b, normalBDH, colors[7]}, {d, normalBDH, colors[7]}, {h, normalBDH, colors[7]},
        {d, normalDJH, colors[8]}, {j, normalDJH, colors[8]}, {h, normalDJH, colors[8]},
        {h, normalHJL, colors[9]}, {j, normalHJL, colors[9]}, {l, normalHJL, colors[9]},
        {j, normalJKL, colors[10]}, {k, normalJKL, colors[10]}, {l, normalJKL, colors[10]},
        {g, normalGLK, colors[11]}, {l, normalGLK, colors[11]}, {k, normalGLK, colors[11]},
        {e, normalEGK, colors[12]}, {g, normalEGK, colors[12]}, {k, normalEGK, colors[12]},
        {a, normalAGE, colors[13]}, {g, normalAGE, colors[13]}, {e, normalAGE, colors[13]},
        {a, normalAEC, colors[14]}, {e, normalAEC, colors[14]}, {c, normalAEC, colors[14]},
        {c, normalCID, colors[15]}, {i, normalCID, colors[15]}, {d, normalCID, colors[15]},
        {d, normalDIJ, colors[16]}, {i, normalDIJ, colors[16]}, {j, normalDIJ, colors[16]},
        {i, normalIKJ, colors[17]}, {k, normalIKJ, colors[17]}, {j, normalIKJ, colors[17]},
        {e, normalEKI, colors[18]}, {k, normalEKI, colors[18]}, {i, normalEKI, colors[18]},
        {c, normalCEI, colors[19]}, {e, normalCEI, colors[19]}, {i, normalCEI, colors[19]},
    };

    vertices = malloc(sizeof(icosahedron));
    memcpy(vertices, icosahedron, sizeof(icosahedron));
}

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    self.effect.transform.projectionMatrix = projectionMatrix;

    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -8.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotation, 0.0f, 1.0f, 0.0f);

    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    rotation += self.timeSinceLastUpdate * 2;
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
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * 3 * 20, vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, color));

    glDrawArrays(GL_TRIANGLES, 0, 3 * 20);
}

@end
