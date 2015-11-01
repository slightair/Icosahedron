attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;

varying lowp vec4 colorVarying;
varying lowp vec4 vColor;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colorVarying = diffuseColor * nDotVP;
    vColor = color;

    gl_Position = modelViewProjectionMatrix * position;
    gl_PointSize = 32.0;
}
