import GLKit

public func == (lhs: GLKVector3, rhs: GLKVector3) -> Bool {
    return GLKVector3AllEqualToVector3(lhs, rhs)
}

extension GLKVector3: Hashable {
    public var hashValue: Int {
        return NSStringFromGLKVector3(self).hashValue
    }
}
