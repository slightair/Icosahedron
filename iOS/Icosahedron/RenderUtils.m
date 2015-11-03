#import "RenderUtils.h"

@implementation RenderUtils

+ (BOOL)loadShaders:(GLuint *)program path:(NSString *)path
{
    GLuint newProgram = glCreateProgram();

    GLuint vertShader = 0;
    NSString *vertShaderPathName = [[NSBundle mainBundle] pathForResource:path ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathName]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    GLuint fragShader = 0;
    NSString *fragShaderPathName = [[NSBundle mainBundle] pathForResource:path ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathName]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }

    glAttachShader(newProgram, vertShader);
    glAttachShader(newProgram, fragShader);

    if (![self linkProgram:newProgram]) {
        NSLog(@"Failed to link program: %d", newProgram);

        if (vertShader != 0) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader != 0) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (newProgram != 0) {
            glDeleteProgram(newProgram);
            newProgram = 0;
        }

        return NO;
    }

    if (vertShader != 0) {
        glDetachShader(newProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader != 0) {
        glDetachShader(newProgram, fragShader);
        glDeleteShader(fragShader);
    }

    *program = newProgram;

    return YES;
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
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

+ (BOOL)linkProgram:(GLuint)prog
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

+ (BOOL)validateProgram:(GLuint)prog
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
