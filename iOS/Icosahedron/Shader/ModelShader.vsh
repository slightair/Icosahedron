#version 300 es

layout (location = 0) in vec4 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec4 color;

out lowp vec4 colorVarying;

uniform mat4 projectionMatrix;
uniform mat4 worldMatrix;
uniform mat3 normalMatrix;
uniform mat4 modelMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * mat3(modelMatrix) * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));

    colorVarying = diffuseColor * nDotVP * color;

    gl_Position = projectionMatrix * worldMatrix * modelMatrix * position;
}
