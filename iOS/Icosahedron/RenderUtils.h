@import Foundation;
@import OpenGLES;

NS_ASSUME_NONNULL_BEGIN

@interface RenderUtils : NSObject

+ (BOOL)loadShaders:(GLuint *)program path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
