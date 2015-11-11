#version 300 es

layout (location = 0) in vec4 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec4 color;

out lowp vec4 colorVarying;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colorVarying = diffuseColor * nDotVP * color;

    gl_Position = projectionMatrix * modelViewMatrix * position;
    gl_PointSize = 24.0;
}
