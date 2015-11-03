#version 300 es

layout (location = 0) in vec4 position;
layout (location = 2) in vec4 color;

out lowp vec4 colorVarying;
out mediump vec2 texcoord;

void main()
{
    colorVarying = color;
    texcoord = position.xy * 0.5 + 0.5;
    gl_Position = position;
}
