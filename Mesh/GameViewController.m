#import "GameViewController.h"
@import OpenGLES;
@import UIKit;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

const NSInteger NUM_VERTICES = 128;
const NSInteger NUM_SPLIT = 24;

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
    vertices = malloc(sizeof(GLfloat) * 7 * NUM_VERTICES);
    indices = malloc(sizeof(GLubyte) * (NUM_SPLIT * 2 + NUM_VERTICES * 4));
    indicesCount = 0;

    vertices[0] = 0.0; vertices[1] = 0.0; vertices[2] = 0.0;
    vertices[3] = 1.0; vertices[4] = 1.0; vertices[5] = 1.0; vertices[6] = 1.0;

    for (int i = 1; i <= NUM_SPLIT; i++) {
        indices[indicesCount++] = 0;
        indices[indicesCount++] = i;
    }

    for (int i = 1; i < NUM_VERTICES; i++) {
        int base;
        double theta = 2 * M_PI / NUM_SPLIT * i;
        double radius = 0.05 * theta;

        base = i * 7;
        vertices[base + 0] = radius * cos(theta);
        vertices[base + 1] = radius * sin(theta);
        vertices[base + 2] = 0.0;

        UIColor *color = [UIColor colorWithHue:fmod(theta, (2 * M_PI)) / (2 * M_PI) saturation:0.5 brightness:1.0 alpha:1.0];
        CGFloat red, green, blue;
        [color getRed:&red green:&green blue:&blue alpha:NULL];
        vertices[base + 3] = (GLfloat)red;
        vertices[base + 4] = (GLfloat)green;
        vertices[base + 5] = (GLfloat)blue;
        vertices[base + 6] = 1.0;

        if (i + 1 < NUM_VERTICES) {
            indices[indicesCount++] = i;
            indices[indicesCount++] = i + 1;
        }

        if (i + NUM_SPLIT < NUM_VERTICES) {
            indices[indicesCount++] = i;
            indices[indicesCount++] = i + NUM_SPLIT;
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
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 7 * NUM_VERTICES, vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLubyte) * indicesCount, indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    GLsizei stride = sizeof(GLfloat) * 7;
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(GLfloat) * 3));

    glDrawElements(GL_LINE_STRIP, indicesCount, GL_UNSIGNED_BYTE, NULL);
}

@end
