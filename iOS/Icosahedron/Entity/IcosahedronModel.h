@import GLKit;
#import "Icosahedron-Swift.h"

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector4 color;
} Vertex;

extern const int IcosahedronModelNumberOfPointVertices;
extern const int IcosahedronModelNumberOfLineVertices;
extern const int IcosahedronModelNumberOfFaceVertices;

NS_ASSUME_NONNULL_BEGIN

@interface IcosahedronModel : NSObject

@property (nonatomic, readonly) Vertex *pointVertices;
@property (nonatomic, readonly) Vertex *lineVertices;
@property (nonatomic, readonly) Vertex *faceVertices;
@property (nonatomic, readonly) NSDictionary<NSString *, IcosahedronVertex *> *vertexDict;

@end

NS_ASSUME_NONNULL_END
