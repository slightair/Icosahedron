#version 300 es

layout (location = 0) in vec4 position;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 texCoord;

out lowp vec4 vColor;
out lowp vec2 vTexCoord;

uniform mat4 uProjectionMatrix;
uniform mat4 uWorldMatrix;
uniform mat3 uNormalMatrix;

void main()
{
    vec3 eyeNormal = normalize(uNormalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = max(0.6, dot(eyeNormal, normalize(lightPosition)));

    vColor = diffuseColor * nDotVP * color;
    vColor.a = 1.0;
    vTexCoord = texCoord;

    gl_Position = uProjectionMatrix * uWorldMatrix * position;
}
