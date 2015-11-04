#import "IcosahedronModel.h"

const int IcosahedronModelNumberOfPointVertices = 12;
const int IcosahedronModelNumberOfLineVertices = 30 * 2;

GLKQuaternion quaternionForRotate(IcosahedronVertex *from, IcosahedronVertex *to) {
    GLKVector3 normalizedFrom = GLKVector3Normalize(from.coordinate);
    GLKVector3 normalizedTo = GLKVector3Normalize(to.coordinate);

    float cosTheta = GLKVector3DotProduct(normalizedFrom, normalizedTo);
    GLKVector3 rotationAxis = GLKVector3CrossProduct(normalizedFrom, normalizedTo);

    float s = sqrtf((1 + cosTheta) * 2);
    float inverse = 1 / s;

    return GLKQuaternionMakeWithVector3(GLKVector3MultiplyScalar(rotationAxis, inverse), s * 0.5);
}

@interface IcosahedronModel ()

@property (nonatomic) Vertex *pointVertices;
@property (nonatomic) Vertex *lineVertices;
@property (nonatomic) NSDictionary<NSString *, IcosahedronVertex *> *vertexDict;

@end

@implementation IcosahedronModel
{
    GLKVector3 coordA;
    GLKVector3 coordB;
    GLKVector3 coordC;
    GLKVector3 coordD;
    GLKVector3 coordE;
    GLKVector3 coordF;
    GLKVector3 coordG;
    GLKVector3 coordH;
    GLKVector3 coordI;
    GLKVector3 coordJ;
    GLKVector3 coordK;
    GLKVector3 coordL;

    GLKVector4 colorA;
    GLKVector4 colorB;
    GLKVector4 colorC;
    GLKVector4 colorD;
    GLKVector4 colorE;
    GLKVector4 colorF;
    GLKVector4 colorG;
    GLKVector4 colorH;
    GLKVector4 colorI;
    GLKVector4 colorJ;
    GLKVector4 colorK;
    GLKVector4 colorL;
}

- (nonnull instancetype)init
{
    self = [super init];

    [self createVertices];
    [self createPoints];
    [self createLines];
    [self createVertexDict];

    return self;
}

- (void)dealloc
{
    free(_pointVertices);
    free(_lineVertices);
}

- (void)createVertices
{
    const float scale = 0.15;
    const float x = (1 + sqrt(5)) / 2;

    coordG = GLKVector3MultiplyScalar(GLKVector3Make( x,  0,  1), scale);
    coordE = GLKVector3MultiplyScalar(GLKVector3Make( x,  0, -1), scale);
    coordH = GLKVector3MultiplyScalar(GLKVector3Make(-x,  0,  1), scale);
    coordD = GLKVector3MultiplyScalar(GLKVector3Make(-x,  0, -1), scale);

    coordA = GLKVector3MultiplyScalar(GLKVector3Make( 1,  x,  0), scale);
    coordB = GLKVector3MultiplyScalar(GLKVector3Make(-1,  x,  0), scale);
    coordK = GLKVector3MultiplyScalar(GLKVector3Make( 1, -x,  0), scale);
    coordJ = GLKVector3MultiplyScalar(GLKVector3Make(-1, -x,  0), scale);

    coordF = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1,  x), scale);
    coordL = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1,  x), scale);
    coordC = GLKVector3MultiplyScalar(GLKVector3Make( 0,  1, -x), scale);
    coordI = GLKVector3MultiplyScalar(GLKVector3Make( 0, -1, -x), scale);

    colorA = GLKVector4Make(0.902, 0.0,   0.071, 1.0);
    colorB = GLKVector4Make(0.953, 0.596, 0.0,   1.0);
    colorC = GLKVector4Make(1.0,   0.945, 0.0,   1.0);
    colorD = GLKVector4Make(0.561, 0.765, 0.122, 1.0);
    colorE = GLKVector4Make(0.0,   0.6,   0.267, 1.0);
    colorF = GLKVector4Make(0.0,   0.62,  0.588, 1.0);
    colorG = GLKVector4Make(0.0,   0.627, 0.914, 1.0);
    colorH = GLKVector4Make(0.0,   0.408, 0.718, 1.0);
    colorI = GLKVector4Make(0.114, 0.125, 0.533, 1.0);
    colorJ = GLKVector4Make(0.573, 0.027, 0.514, 1.0);
    colorK = GLKVector4Make(0.894, 0.0,   0.498, 1.0);
    colorL = GLKVector4Make(0.898, 0.0,   0.31,  1.0);
}

- (void)createPoints
{
    Vertex points[] = {
        {coordA, coordA, colorA},
        {coordB, coordB, colorB},
        {coordC, coordC, colorC},
        {coordD, coordD, colorD},
        {coordE, coordE, colorE},
        {coordF, coordF, colorF},
        {coordG, coordG, colorG},
        {coordH, coordH, colorH},
        {coordI, coordI, colorI},
        {coordJ, coordJ, colorJ},
        {coordK, coordK, colorK},
        {coordL, coordL, colorL},
    };

    _pointVertices = malloc(sizeof(points));
    memcpy(_pointVertices, points, sizeof(points));
}

- (void)createLines
{
    GLKVector4 lineColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);

    Vertex lines[] = {
        {coordA, coordA, lineColor}, {coordB, coordB, lineColor},
        {coordA, coordA, lineColor}, {coordC, coordC, lineColor},
        {coordA, coordA, lineColor}, {coordE, coordE, lineColor},
        {coordA, coordA, lineColor}, {coordF, coordF, lineColor},
        {coordA, coordA, lineColor}, {coordG, coordG, lineColor},
        {coordB, coordB, lineColor}, {coordC, coordC, lineColor},
        {coordB, coordB, lineColor}, {coordD, coordD, lineColor},
        {coordB, coordB, lineColor}, {coordF, coordF, lineColor},
        {coordB, coordB, lineColor}, {coordH, coordH, lineColor},
        {coordC, coordC, lineColor}, {coordD, coordD, lineColor},
        {coordC, coordC, lineColor}, {coordE, coordE, lineColor},
        {coordC, coordC, lineColor}, {coordI, coordI, lineColor},
        {coordD, coordD, lineColor}, {coordH, coordH, lineColor},
        {coordD, coordD, lineColor}, {coordI, coordI, lineColor},
        {coordD, coordD, lineColor}, {coordJ, coordJ, lineColor},
        {coordE, coordE, lineColor}, {coordG, coordG, lineColor},
        {coordE, coordE, lineColor}, {coordI, coordI, lineColor},
        {coordE, coordE, lineColor}, {coordK, coordK, lineColor},
        {coordF, coordF, lineColor}, {coordG, coordG, lineColor},
        {coordF, coordF, lineColor}, {coordH, coordH, lineColor},
        {coordF, coordF, lineColor}, {coordL, coordL, lineColor},
        {coordG, coordG, lineColor}, {coordK, coordK, lineColor},
        {coordG, coordG, lineColor}, {coordL, coordL, lineColor},
        {coordH, coordH, lineColor}, {coordJ, coordJ, lineColor},
        {coordH, coordH, lineColor}, {coordL, coordL, lineColor},
        {coordI, coordI, lineColor}, {coordJ, coordJ, lineColor},
        {coordI, coordI, lineColor}, {coordK, coordK, lineColor},
        {coordJ, coordJ, lineColor}, {coordK, coordK, lineColor},
        {coordJ, coordJ, lineColor}, {coordL, coordL, lineColor},
        {coordK, coordK, lineColor}, {coordL, coordL, lineColor},
    };

    _lineVertices = malloc(sizeof(lines));
    memcpy(_lineVertices, lines, sizeof(lines));
}

- (void)createVertexDict
{
    NSArray *vertices = @[
                          [[IcosahedronVertex alloc] initWithName:@"A" coordinate:coordA],
                          [[IcosahedronVertex alloc] initWithName:@"B" coordinate:coordB],
                          [[IcosahedronVertex alloc] initWithName:@"C" coordinate:coordC],
                          [[IcosahedronVertex alloc] initWithName:@"D" coordinate:coordD],
                          [[IcosahedronVertex alloc] initWithName:@"E" coordinate:coordE],
                          [[IcosahedronVertex alloc] initWithName:@"F" coordinate:coordF],
                          [[IcosahedronVertex alloc] initWithName:@"G" coordinate:coordG],
                          [[IcosahedronVertex alloc] initWithName:@"H" coordinate:coordH],
                          [[IcosahedronVertex alloc] initWithName:@"I" coordinate:coordI],
                          [[IcosahedronVertex alloc] initWithName:@"J" coordinate:coordJ],
                          [[IcosahedronVertex alloc] initWithName:@"K" coordinate:coordK],
                          [[IcosahedronVertex alloc] initWithName:@"L" coordinate:coordL],
                          ];

    NSMutableDictionary<NSString *, IcosahedronVertex *> *dict = [NSMutableDictionary new];
    for (IcosahedronVertex *vertex in vertices) {
        dict[vertex.name] = vertex;
    }

    dict[@"C"].head      = dict[@"I"];
    dict[@"C"].leftHand  = dict[@"D"];
    dict[@"C"].leftFoot  = dict[@"B"];
    dict[@"C"].rightHand = dict[@"E"];
    dict[@"C"].rightFoot = dict[@"A"];

    dict[@"B"].head      = dict[@"A"];
    dict[@"B"].leftHand  = dict[@"C"];
    dict[@"B"].leftFoot  = dict[@"D"];
    dict[@"B"].rightHand = dict[@"H"];
    dict[@"B"].rightFoot = dict[@"F"];

    dict[@"A"].head      = dict[@"E"];
    dict[@"A"].leftHand  = dict[@"C"];
    dict[@"A"].leftFoot  = dict[@"B"];
    dict[@"A"].rightHand = dict[@"F"];
    dict[@"A"].rightFoot = dict[@"G"];

    dict[@"E"].head      = dict[@"G"];
    dict[@"E"].leftHand  = dict[@"K"];
    dict[@"E"].leftFoot  = dict[@"I"];
    dict[@"E"].rightHand = dict[@"C"];
    dict[@"E"].rightFoot = dict[@"A"];

    dict[@"G"].head      = dict[@"L"];
    dict[@"G"].leftHand  = dict[@"K"];
    dict[@"G"].leftFoot  = dict[@"E"];
    dict[@"G"].rightHand = dict[@"A"];
    dict[@"G"].rightFoot = dict[@"F"];

    dict[@"L"].head      = dict[@"F"];
    dict[@"L"].leftHand  = dict[@"H"];
    dict[@"L"].leftFoot  = dict[@"J"];
    dict[@"L"].rightHand = dict[@"K"];
    dict[@"L"].rightFoot = dict[@"G"];

    dict[@"F"].head      = dict[@"H"];
    dict[@"F"].leftHand  = dict[@"L"];
    dict[@"F"].leftFoot  = dict[@"G"];
    dict[@"F"].rightHand = dict[@"A"];
    dict[@"F"].rightFoot = dict[@"B"];

    dict[@"H"].head      = dict[@"J"];
    dict[@"H"].leftHand  = dict[@"L"];
    dict[@"H"].leftFoot  = dict[@"F"];
    dict[@"H"].rightHand = dict[@"B"];
    dict[@"H"].rightFoot = dict[@"D"];

    dict[@"J"].head      = dict[@"K"];
    dict[@"J"].leftHand  = dict[@"L"];
    dict[@"J"].leftFoot  = dict[@"H"];
    dict[@"J"].rightHand = dict[@"D"];
    dict[@"J"].rightFoot = dict[@"I"];

    dict[@"K"].head      = dict[@"I"];
    dict[@"K"].leftHand  = dict[@"E"];
    dict[@"K"].leftFoot  = dict[@"G"];
    dict[@"K"].rightHand = dict[@"L"];
    dict[@"K"].rightFoot = dict[@"J"];

    dict[@"I"].head      = dict[@"D"];
    dict[@"I"].leftHand  = dict[@"C"];
    dict[@"I"].leftFoot  = dict[@"E"];
    dict[@"I"].rightHand = dict[@"K"];
    dict[@"I"].rightFoot = dict[@"J"];

    dict[@"D"].head      = dict[@"C"];
    dict[@"D"].leftHand  = dict[@"I"];
    dict[@"D"].leftFoot  = dict[@"J"];
    dict[@"D"].rightHand = dict[@"H"];
    dict[@"D"].rightFoot = dict[@"B"];

    self.vertexDict = dict;
}

@end
