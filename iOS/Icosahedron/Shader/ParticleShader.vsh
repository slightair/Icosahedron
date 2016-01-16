#version 300 es

layout (location = 0) in vec4 position;
layout (location = 2) in vec4 color;

out lowp vec4 vColor;

uniform mat4 uProjectionMatrix;
uniform mat4 uWorldMatrix;

void main()
{
    vColor = color;
    gl_Position = uProjectionMatrix * uWorldMatrix * position;
    gl_PointSize = 48.0;
}
