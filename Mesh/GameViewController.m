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

    GLKVector4 color = GLKVector4Make(1, 1, 1, 1);

    GLKVector3 normalABC = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, b), GLKVector3Subtract(b, c)));
    GLKVector3 normalAEG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, e), GLKVector3Subtract(e, g)));
    GLKVector3 normalAFG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, f), GLKVector3Subtract(f, g)));
    GLKVector3 normalABF = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, b), GLKVector3Subtract(b, f)));
    GLKVector3 normalACE = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(a, c), GLKVector3Subtract(c, e)));
    GLKVector3 normalBCD = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, c), GLKVector3Subtract(c, d)));
    GLKVector3 normalBDH = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, d), GLKVector3Subtract(d, h)));
    GLKVector3 normalBFH = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(b, f), GLKVector3Subtract(f, h)));
    GLKVector3 normalCEI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(c, e), GLKVector3Subtract(e, i)));
    GLKVector3 normalCDI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(c, d), GLKVector3Subtract(d, i)));
    GLKVector3 normalDJI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(d, j), GLKVector3Subtract(j, i)));
    GLKVector3 normalDHJ = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(d, h), GLKVector3Subtract(h, j)));
    GLKVector3 normalEKG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(e, k), GLKVector3Subtract(k, g)));
    GLKVector3 normalEKI = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(e, k), GLKVector3Subtract(k, i)));
    GLKVector3 normalFHL = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(f, h), GLKVector3Subtract(h, l)));
    GLKVector3 normalFLG = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(f, l), GLKVector3Subtract(l, g)));
    GLKVector3 normalGLK = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(g, l), GLKVector3Subtract(l, k)));
    GLKVector3 normalHLJ = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(h, l), GLKVector3Subtract(l, j)));
    GLKVector3 normalIKJ = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(i, k), GLKVector3Subtract(k, j)));
    GLKVector3 normalJKL = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(j, k), GLKVector3Subtract(k, l)));

    Vertex icosahedron[] = {
        {a, normalABC, color},
        {b, normalABC, color},
        {c, normalABC, color},

        {a, normalAEG, color},
        {e, normalAEG, color},
        {g, normalAEG, color},

        {a, normalAFG, color},
        {f, normalAFG, color},
        {g, normalAFG, color},

        {a, normalABF, color},
        {b, normalABF, color},
        {f, normalABF, color},

        {a, normalACE, color},
        {c, normalACE, color},
        {e, normalACE, color},

        {b, normalBCD, color},
        {c, normalBCD, color},
        {d, normalBCD, color},

        {b, normalBDH, color},
        {d, normalBDH, color},
        {h, normalBDH, color},

        {b, normalBFH, color},
        {f, normalBFH, color},
        {h, normalBFH, color},

        {c, normalCEI, color},
        {e, normalCEI, color},
        {i, normalCEI, color},

        {c, normalCDI, color},
        {d, normalCDI, color},
        {i, normalCDI, color},

        {d, normalDJI, color},
        {j, normalDJI, color},
        {i, normalDJI, color},

        {d, normalDHJ, color},
        {h, normalDHJ, color},
        {j, normalDHJ, color},

        {e, normalEKG, color},
        {k, normalEKG, color},
        {g, normalEKG, color},

        {e, normalEKI, color},
        {k, normalEKI, color},
        {i, normalEKI, color},

        {f, normalFHL, color},
        {h, normalFHL, color},
        {l, normalFHL, color},

        {f, normalFLG, color},
        {l, normalFLG, color},
        {g, normalFLG, color},

        {g, normalGLK, color},
        {l, normalGLK, color},
        {k, normalGLK, color},

        {h, normalHLJ, color},
        {l, normalHLJ, color},
        {j, normalHLJ, color},

        {i, normalIKJ, color},
        {k, normalIKJ, color},
        {j, normalIKJ, color},

        {j, normalJKL, color},
        {k, normalJKL, color},
        {l, normalJKL, color},
    };

    vertices = malloc(sizeof(icosahedron));
    memcpy(vertices, icosahedron, sizeof(icosahedron));
}

#pragma mark - GLKViewDelegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.6, 0.6, 0.6, 1.0);

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
