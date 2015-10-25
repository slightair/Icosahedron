attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = dot(normal, normalize(lightPosition));

    colorVarying = diffuseColor * nDotVP;

    gl_Position = modelViewProjectionMatrix * position;
}
