import OpenGLES

class RenderUtils {
    class func loadShaders(inout program: GLuint, path: String) -> Bool {
        let program = glCreateProgram()

        var vertexShader: GLuint = 0
        let vertexShaderPathName = NSBundle.mainBundle().pathForResource(path, ofType: "vsh")!
        if !compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), file: vertexShaderPathName) {
            fatalError("Failed to compile vertex shader")
        }

        var fragmentShader: GLuint = 0
        let fragmentShaderPathName = NSBundle.mainBundle().pathForResource(path, ofType: "fsh")!
        if !compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragmentShaderPathName) {
            fatalError("Failed to compile fragment shader")
        }

        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)

        if !linkProgram(program) {
            if vertexShader != 0 {
                glDeleteShader(vertexShader)
            }

            if fragmentShader != 0 {
                glDeleteShader(fragmentShader)
            }

            if program != 0 {
                glDeleteProgram(program)
            }

            fatalError("Failed to link program: \(program)")
        }

        if vertexShader != 0 {
            glDetachShader(program, vertexShader)
            glDeleteShader(vertexShader)
        }

        if fragmentShader != 0 {
            glDetachShader(program, fragmentShader)
            glDeleteShader(fragmentShader)
        }

        return true
    }

    class func compileShader(inout shader: GLuint, type: GLenum, file: String) -> Bool {
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding).UTF8String
        } catch {
            fatalError("Failed to load shader")
        }
        var castSource = UnsafePointer<GLchar>(source)

        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)

        var logLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength);
        if logLength > 0 {
            let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            NSLog("Shader compile log: \n%s", log);
            free(log)
        }

        var status:GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == 0 {
            glDeleteShader(shader);
            return false
        }
        return true
    }

    class func linkProgram(program: GLuint) -> Bool {
        glLinkProgram(program)

        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
            glGetProgramInfoLog(program, logLength, &logLength, log)
            print("Program link log:\n\(log)")
            free(log)
        }

        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            return false
        }
        return true
    }

    class func validateProgram(program: GLuint) -> Bool {
        glValidateProgram(program)

        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
            glGetProgramInfoLog(program, logLength, &logLength, log)
            print("Program validate log:\n\(log)")
            free(log)
        }

        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_VALIDATE_STATUS), &status)
        if status == 0 {
            return false
        }
        return true
    }
}
