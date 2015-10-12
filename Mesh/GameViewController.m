#import "GameViewController.h"
@import OpenGLES;
@import UIKit;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

const NSInteger NUM_VERTICES = 19;

@interface GameViewController ()

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKBaseEffect *effect;

@end

@implementation GameViewController
{
    GLuint vertexBufferID;
    GLuint indexBufferID;
    GLfloat *vertices;
    GLubyte *indices;
    int indicesCount;
    int verticesCount;
    NSInteger *sequence;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &vertexBufferID);
    glDeleteBuffers(1, &indexBufferID);

    self.context = nil;

    [EAGLContext setCurrentContext:nil];

    free(vertices);
    free(indices);
    free(sequence);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView *glkView = (GLKView *)self.view;
    glkView.context = self.context;

    [EAGLContext setCurrentContext:self.context];

    self.effect = [GLKBaseEffect new];
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);

    glClearColor(0.0, 0.0, 0.0, 1.0);

    [self createVertices];
}

- (void)createVertices
{
    vertices = malloc(sizeof(GLfloat) * 7 * NUM_VERTICES * 3);
    indices = malloc(sizeof(GLubyte) * NUM_VERTICES * 3);
    verticesCount = 0;
    indicesCount = 0;
    sequence = malloc(sizeof(NSInteger) * NUM_VERTICES);

    for (int i = 0; i < NUM_VERTICES; i++) {
        if (i < 3) {
            sequence[i] = 1;
        } else {
            sequence[i] = sequence[i-2] + sequence[i-3];
        }

        GLfloat radius = sequence[i] * 0.05;
        double theta = 2 * M_PI / 6 * i;
        UIColor *color = [UIColor colorWithHue:fmod(theta, (2 * M_PI)) / (2 * M_PI) saturation:0.5 brightness:1.0 alpha:1.0];
        CGFloat red, green, blue;
        [color getRed:&red green:&green blue:&blue alpha:NULL];

        GLfloat baseX, baseY;
        if (i == 0) {
            baseX = 0.0;
            baseY = 0.0;
        } else {
            int offset = (i - 1) * 7 * 3 + 7;
            baseX = vertices[offset + 0];
            baseY = vertices[offset + 1];
        }

        for (int v = 0; v < 3; v++) {
            if (v == 0) {
                vertices[verticesCount++] = baseX;
                vertices[verticesCount++] = baseY;
            } else {
                double alpha = -(theta + 2 * M_PI / 6 * v);
                vertices[verticesCount++] = baseX + radius * cos(alpha);
                vertices[verticesCount++] = baseY + radius * sin(alpha);
            }
            vertices[verticesCount++] = 0.0;

            vertices[verticesCount++] = (GLfloat)red;
            vertices[verticesCount++] = (GLfloat)green;
            vertices[verticesCount++] = (GLfloat)blue;
            vertices[verticesCount++] = 1.0;

            indices[indicesCount++] = indicesCount;
        }
    }
}

#pragma mark - GLKViewDelegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.effect prepareToDraw];

    glClear(GL_COLOR_BUFFER_BIT);

    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * verticesCount, vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLubyte) * indicesCount, indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    GLsizei stride = sizeof(GLfloat) * 7;
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(GLfloat) * 3));

    glDrawElements(GL_TRIANGLES, indicesCount, GL_UNSIGNED_BYTE, NULL);
}

@end
