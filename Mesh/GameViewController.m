#import "GameViewController.h"
@import OpenGLES;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

const GLfloat vertices[] = {
     0.5, -0.5, 0.0,  0.0, 0.0, 1.0, 1.0,
    -0.5, -0.5, 0.0,  1.0, 0.0, 0.0, 1.0,
    -0.5,  0.5, 0.0,  0.0, 1.0, 0.0, 1.0,
     0.5,  0.5, 0.0,  1.0, 1.0, 0.0, 1.0,
};

const GLubyte indices[] = {
    0, 1, 2,
    0, 3, 2,
};

@interface GameViewController ()

@property (nonatomic) EAGLContext *context;
@property (nonatomic) GLKBaseEffect *effect;

@end

@implementation GameViewController
{
    GLuint vertexBufferID;
    GLuint indexBufferID;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &vertexBufferID);
    glDeleteBuffers(1, &indexBufferID);

    self.context = nil;

    [EAGLContext setCurrentContext:nil];
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
}

#pragma mark - GLKViewDelegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.effect prepareToDraw];

    glClear(GL_COLOR_BUFFER_BIT);

    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &indexBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    GLsizei stride = sizeof(GLfloat) * 7;
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(0));
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET(sizeof(GLfloat) * 3));

    glDrawElements(GL_LINE_LOOP, sizeof(indices) / sizeof(GLubyte), GL_UNSIGNED_BYTE, NULL);
}

@end
