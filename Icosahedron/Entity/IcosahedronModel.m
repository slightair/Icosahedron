#import "IcosahedronModel.h"

const int IcosahedronModelNumberOfFaceVertices = 3 * 20;

GLKVector3 createFaceNormal(GLKVector3 x, GLKVector3 y, GLKVector3 z) {
    return GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(x, y), GLKVector3Subtract(y, z)));
}

@interface IcosahedronModel ()

@property (nonatomic) Vertex *vertices;
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
}

- (nonnull instancetype)init
{
    self = [super init];

    [self createVertices];
    [self createFaces];
    [self createIcosahedronVertices];

    return self;
}

- (void)dealloc
{
    free(_vertices);
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
}

- (void)createFaces
{
    GLKVector3 faceNormalABF = createFaceNormal(coordA, coordB, coordF);
    GLKVector3 faceNormalACB = createFaceNormal(coordA, coordC, coordB);
    GLKVector3 faceNormalAEC = createFaceNormal(coordA, coordE, coordC);
    GLKVector3 faceNormalAFG = createFaceNormal(coordA, coordF, coordG);
    GLKVector3 faceNormalAGE = createFaceNormal(coordA, coordG, coordE);
    GLKVector3 faceNormalBCD = createFaceNormal(coordB, coordC, coordD);
    GLKVector3 faceNormalBDH = createFaceNormal(coordB, coordD, coordH);
    GLKVector3 faceNormalBHF = createFaceNormal(coordB, coordH, coordF);
    GLKVector3 faceNormalCEI = createFaceNormal(coordC, coordE, coordI);
    GLKVector3 faceNormalCID = createFaceNormal(coordC, coordI, coordD);
    GLKVector3 faceNormalDIJ = createFaceNormal(coordD, coordI, coordJ);
    GLKVector3 faceNormalDJH = createFaceNormal(coordD, coordJ, coordH);
    GLKVector3 faceNormalEGK = createFaceNormal(coordE, coordG, coordK);
    GLKVector3 faceNormalEKI = createFaceNormal(coordE, coordK, coordI);
    GLKVector3 faceNormalFHL = createFaceNormal(coordF, coordH, coordL);
    GLKVector3 faceNormalFLG = createFaceNormal(coordF, coordL, coordG);
    GLKVector3 faceNormalGLK = createFaceNormal(coordG, coordL, coordK);
    GLKVector3 faceNormalHJL = createFaceNormal(coordH, coordJ, coordL);
    GLKVector3 faceNormalIKJ = createFaceNormal(coordI, coordK, coordJ);
    GLKVector3 faceNormalJKL = createFaceNormal(coordJ, coordK, coordL);

    GLKVector4 color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);

    Vertex faces[] = {
        {coordA, faceNormalACB, GLKVector4Make(1.0, 0.0, 0.0, 1.0)},
        {coordC, faceNormalACB, GLKVector4Make(0.0, 1.0, 0.0, 1.0)},
        {coordB, faceNormalACB, GLKVector4Make(0.0, 0.0, 1.0, 1.0)},

        {coordA, faceNormalABF, color}, {coordB, faceNormalABF, color}, {coordF, faceNormalABF, color},
//        {coordA, faceNormalACB, color}, {coordC, faceNormalACB, color}, {coordB, faceNormalACB, color},
        {coordA, faceNormalAEC, color}, {coordE, faceNormalAEC, color}, {coordC, faceNormalAEC, color},
        {coordA, faceNormalAFG, color}, {coordF, faceNormalAFG, color}, {coordG, faceNormalAFG, color},
        {coordA, faceNormalAGE, color}, {coordG, faceNormalAGE, color}, {coordE, faceNormalAGE, color},
        {coordB, faceNormalBCD, color}, {coordC, faceNormalBCD, color}, {coordD, faceNormalBCD, color},
        {coordB, faceNormalBDH, color}, {coordD, faceNormalBDH, color}, {coordH, faceNormalBDH, color},
        {coordB, faceNormalBHF, color}, {coordH, faceNormalBHF, color}, {coordF, faceNormalBHF, color},
        {coordC, faceNormalCEI, color}, {coordE, faceNormalCEI, color}, {coordI, faceNormalCEI, color},
        {coordC, faceNormalCID, color}, {coordI, faceNormalCID, color}, {coordD, faceNormalCID, color},
        {coordD, faceNormalDIJ, color}, {coordI, faceNormalDIJ, color}, {coordJ, faceNormalDIJ, color},
        {coordD, faceNormalDJH, color}, {coordJ, faceNormalDJH, color}, {coordH, faceNormalDJH, color},
        {coordE, faceNormalEGK, color}, {coordG, faceNormalEGK, color}, {coordK, faceNormalEGK, color},
        {coordE, faceNormalEKI, color}, {coordK, faceNormalEKI, color}, {coordI, faceNormalEKI, color},
        {coordF, faceNormalFHL, color}, {coordH, faceNormalFHL, color}, {coordL, faceNormalFHL, color},
        {coordF, faceNormalFLG, color}, {coordL, faceNormalFLG, color}, {coordG, faceNormalFLG, color},
        {coordG, faceNormalGLK, color}, {coordL, faceNormalGLK, color}, {coordK, faceNormalGLK, color},
        {coordH, faceNormalHJL, color}, {coordJ, faceNormalHJL, color}, {coordL, faceNormalHJL, color},
        {coordI, faceNormalIKJ, color}, {coordK, faceNormalIKJ, color}, {coordJ, faceNormalIKJ, color},
        {coordJ, faceNormalJKL, color}, {coordK, faceNormalJKL, color}, {coordL, faceNormalJKL, color},
    };

    _vertices = malloc(sizeof(faces));
    memcpy(_vertices, faces, sizeof(faces));
}

- (void)createIcosahedronVertices
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
