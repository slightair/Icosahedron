#version 300 es

layout (location = 0) in vec4 position;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 texCoord;

out lowp vec4 vColor;
out lowp vec2 vTexCoord;

uniform mat4 uProjectionMatrix;

void main()
{
    vColor = color;
    vTexCoord = texCoord;

    gl_Position = position * vec4(1, -1, 1, 1) * uProjectionMatrix;
}
